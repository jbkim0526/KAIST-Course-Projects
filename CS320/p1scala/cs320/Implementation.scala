package cs320

import Value._

object Implementation extends Template {

  def interp(expr: Expr, env: Env): Value = expr match {
    
    case Id(name: String) => env.getOrElse(name, error(s"free identifier: $name"))
    case IntE(value: BigInt) => IntV(value)
    case BooleanE(value: Boolean) => BooleanV(value)
    case Add(left: Expr, right: Expr) => IntVadd(interp(left,env),interp(right,env))
    case Mul(left: Expr, right: Expr) => IntVmul(interp(left,env),interp(right,env))
    case Div(left: Expr, right: Expr) => IntVdiv(interp(left,env),interp(right,env))
    case Mod(left: Expr, right: Expr) => IntVmod(interp(left,env),interp(right,env))
    case Eq(left: Expr, right: Expr) => IntVeq(interp(left,env),interp(right,env))
    case Lt(left: Expr, right: Expr) => IntVlt(interp(left,env),interp(right,env))
    case If(condition: Expr, trueBranch: Expr, falseBranch: Expr) => interp(condition,env) match {
      case BooleanV(bool: Boolean) => if(bool) interp(trueBranch,env) else interp(falseBranch,env)
      case _ => error(s"type mismatch")
    }
    case TupleE(expressions: List[Expr]) => {
      def makeTuple(expr: List[Expr]): List[Value] = expr match {
        case Nil => Nil
        case h::t => {
          List(interp(h,env)) ++ makeTuple(t)
        }
      }
      TupleV(makeTuple(expressions))
    }
    case Proj(expression: Expr, index: Int) => interp(expression,env) match {
      case TupleV(values: List[Value]) => {
        if(values.length >= index) values(index - 1)
        else error(s"index out of bound")
      }
      case _ => error(s"type mismatch")
    }
    case NilE => NilV 
    case ConsE(head: Expr, tail: Expr) => {
      val headValue = interp(head,env)
      val tailValue = interp(tail,env)
      tailValue match {
        case ConsV(head: Value, tail: Value) => ConsV(headValue,tailValue)
        case NilV => ConsV(headValue,tailValue)
        case _ => error(s"type mismatch")
      }
    }
    case Empty(expression: Expr) => interp(expression,env) match {
        case NilV => BooleanV(true)
        case ConsV(head: Value, tail: Value) => BooleanV(false)
        case _ => error(s"type mismatch")
    }
    case Head(expression: Expr) => interp(expression,env) match {
      case ConsV(head: Value, tail: Value) => head
      case _ => error(s"type mismatch")
    }
    case Tail(expression: Expr) => interp(expression,env) match {
      case ConsV(head: Value, tail: Value) => tail
      case _ => error(s"type mismatch")
    }
    case Val(name: String, expression: Expr, body: Expr) =>{
      interp(body, env + ( name-> interp(expression,env)))
    } 
    
    case Fun(parameters: List[String], body: Expr) => CloV(parameters, body, env)
    case RecFuns(functions: List[FunDef], body: Expr) => {
      def makeRec(functions: List[FunDef], cenv: Env): Env = functions match {
        case Nil => cenv
        case h::t => {
          val cloV = CloV(h.parameters, h.body, env)
          //val nenv = env + (h.name -> cloV)
          //cloV.env = nenv
          makeRec(t,cenv + (h.name-> cloV))
        }
      }
      def modifyfenv(functions: List[FunDef], cenv: Env): Unit = functions match {
        case Nil => Nil
        case h::t => {
          val cloV = cenv.getOrElse(h.name, error(s"not found"))
          cloV match {
            case ev@CloV(parameters: List[String], body: Expr, fenv: Env) =>
              val nenv = fenv ++ cenv
              ev.env = nenv
          }
          modifyfenv(t,cenv)
        }
      }
      val cenv = makeRec(functions,Map())
      modifyfenv(functions, cenv)
      interp(body, env ++ cenv)
    }
  
    case App(function: Expr, arguments: List[Expr]) => interp(function,env) match {
      case CloV(parameters: List[String], body: Expr, fenv: Env) => {
        val avals = arguments.map(interp(_, env)) 
        if(arguments.length != parameters.length) error(s"numbers not match")
        interp(body, fenv++ (parameters zip avals) )
      }
      case _ => error(s"type mismatch")
    }

    case Test(expression: Expr, typ: Type) => interp(expression,env) match {
      case IntV(value: BigInt) => typ match {
        case IntT => BooleanV(true)
        case _ => BooleanV(false)
      }
      case BooleanV(value: Boolean) => typ match {
        case BooleanT => BooleanV(true)
        case _ => BooleanV(false)
      }
      case TupleV(values: List[Value]) => typ match {
        case TupleT => BooleanV(true)
        case _ => BooleanV(false)
      }
      case NilV => typ match {
        case ListT => BooleanV(true)
        case _ => BooleanV(false)
      }
      case ConsV(head: Value, tail: Value) => typ match {
        case ListT => BooleanV(true)
        case _ => BooleanV(false)
      }
      case CloV(parameters: List[String], body: Expr, env: Env) => typ match {
        case FunctionT => BooleanV(true)
        case _ => BooleanV(false)
      }
    }
  }

  def IntVadd(left: Value, right: Value): Value = (left,right) match{
    case (IntV(x), IntV(y)) => IntV(x+y)
    case _ => error(s"type mismatch")
  }
  def IntVmul(left: Value, right: Value): Value = (left,right) match{
    case (IntV(x), IntV(y)) => IntV(x*y)
    case _ => error(s"type mismatch")
  }
  def IntVdiv(left: Value, right: Value): Value = (left,right) match{
    case (IntV(x), IntV(y)) => {
      if(y == 0) error(s"divide by zero")
      else IntV(x/y) 
    }
    case _ => error(s"type mismatch")
  }
  def IntVmod(left: Value, right: Value): Value = (left,right) match{
    case (IntV(x), IntV(y)) => {
      if(y == 0) error(s"divide by zero")
      else IntV(x%y)
    }
    case _ => error(s"type mismatch")
  }
  def IntVeq(left: Value, right: Value): Value = (left,right) match{
    case (IntV(x), IntV(y)) => {
      if( x == y) BooleanV(true)
      else BooleanV(false)
    }
    case _ => error(s"type mismatch")
  }

  def IntVlt(left: Value, right: Value): Value = (left,right) match{
    case (IntV(x), IntV(y)) => {
      if( x < y) BooleanV(true)
      else BooleanV(false)
    }
    case _ => error(s"type mismatch")
  }
  
  

  def interp(expr: Expr): Value = interp(expr,Map())

}
