package cs320

import Value._

sealed trait Handler 

case object NoH extends Handler
case class ExceptionH(e: Expr, env: Env, k: Cont, h: Handler) extends Handler

object Implementation extends Template {

  def interp(expr: Expr, env: Env, hand: Handler, k: Cont): Value = expr match {

    case Id(name: String) => k(env.getOrElse(name, error(s"free identifier: $name")))
    case IntE(value: BigInt) => k(IntV(value))
    case BooleanE(value: Boolean) => k(BooleanV(value))
    case Add(left: Expr, right: Expr) =>
      interp(left, env, hand, lv => 
        interp(right, env, hand, rv =>
          k(IntVadd(lv,rv))
        )
      )
    case Mul(left: Expr, right: Expr) =>
      interp(left, env, hand, lv => 
        interp(right, env, hand, rv =>
          k(IntVmul(lv,rv))
        )
      )
    case Div(left: Expr, right: Expr) =>
      interp(left, env, hand, lv => 
        interp(right, env, hand, rv =>
          k(IntVdiv(lv,rv))
        )
      )
    case Mod(left: Expr, right: Expr) =>
      interp(left, env, hand, lv => 
        interp(right, env, hand, rv =>
          k(IntVmod(lv,rv))
        )
      )
    case Eq(left: Expr, right: Expr) =>
      interp(left, env, hand, lv => 
        interp(right, env, hand, rv =>
          k(IntVeq(lv,rv))
        )
      )
    case Lt(left: Expr, right: Expr) =>
      interp(left, env, hand, lv => 
        interp(right, env, hand, rv =>
          k(IntVlt(lv,rv))
        )
      )  
    case If(condition: Expr, trueBranch: Expr, falseBranch: Expr) =>
      interp(condition, env, hand, cv =>
        cv match {
          case BooleanV(bool: Boolean) => 
            if(bool) interp(trueBranch, env, hand, k)
            else interp(falseBranch, env, hand, k)
          case _ => error(s"type mismatch")
        }
      )
    case TupleE(expressions: List[Expr]) => 
      def makeTuple(exprs : List[Expr], result: List[Value]): Value = exprs match {
        case Nil => k(TupleV(result))
        case h :: t => 
          interp(h, env, hand, (hv: Value) => 
            makeTuple(t, result :+ hv) 
          )
      }
      makeTuple(expressions, List())
      
    case Proj(expression: Expr, index: Int) =>
      interp(expression, env, hand, ev =>
        ev match {
          case TupleV(values : List[Value]) =>
            if(values.length >= index) k(values(index - 1))
            else error(s"index out of bound")
          case _ => error(s"type mismatch")
        }
      )
    case NilE => k(NilV)
    case ConsE(head: Expr, tail: Expr) => 
      interp(head, env, hand, hv =>
        interp(tail, env, hand, tv => 
          tv match {
            case ConsV(head: Value, tail: Value) => k(ConsV(hv,tv))
            case NilV => k(ConsV(hv,tv))
            case _ => error(s"type mismatch")
          }
        )
      )
    case Empty(expression: Expr) => 
      interp(expression, env, hand, ev =>
        ev match {
          case NilV => k(BooleanV(true))
          case ConsV(head: Value, tail: Value) => k(BooleanV(false))
          case _ => error(s"type mismatch")
        }
      ) 
    case Head(expression: Expr) => 
      interp(expression, env, hand, ev =>
        ev match {
          case ConsV(head: Value, tail: Value) => k(head)
          case _ => error(s"type mismatch")
        }
      ) 
    case Tail(expression: Expr) => 
      interp(expression, env, hand, ev =>
        ev match {
          case ConsV(head: Value, tail: Value) => k(tail)
          case _ => error(s"type mismatch")
        }
      ) 
    case Val(name: String, expression: Expr, body: Expr) =>
      interp(expression, env, hand, ev => 
        interp(body, env + (name -> ev), hand, k)
    )
    case Vcc(name: String, body: Expr) => 
      interp(body, env + (name -> ContV(k)), hand, k)
    
    case Fun(parameters: List[String], body: Expr) => k(CloV(parameters, body, env))

    case RecFuns(functions: List[FunDef], body: Expr) =>
      def makeRec(functions: List[FunDef], cenv: Env): Env = functions match {
        case Nil => cenv
        case h::t => {
          val cloV = CloV(h.parameters, h.body, env)
          makeRec(t,cenv + (h.name-> cloV))
        }
      }
      def modifyfenv(functions: List[FunDef], cenv: Env): Unit = functions match {
        case Nil => ()
        case h::t => {
          val cloV = cenv.getOrElse(h.name, error(s"not found"))
          cloV match {
            case ev@CloV(parameters: List[String], body: Expr, fenv: Env) =>
              val nenv = fenv ++ cenv
              ev.env = nenv
            case _ => error(s"type mismatch")
          }
          modifyfenv(t,cenv)
        }
      }
      val cenv = makeRec(functions,Map())
      modifyfenv(functions, cenv)
      interp(body, env ++ cenv, hand, k)

    case App(function: Expr, arguments: List[Expr]) =>
      def makeArgL(args: List[Expr], avals: List[Value], fv: Value): Value = args match {
        case Nil => fv match {
          case CloV(parameters: List[String], body: Expr, fenv: Env) =>
            if(arguments.length != parameters.length) error(s"numbers not match")
            interp(body, fenv++ (parameters zip avals), hand, k)

          case ContV(kv: Cont) =>
            if(arguments.length != 1) error(s"There are more than one argument in Cont")
            avals match {
              case h::t => kv(h)
              case Nil => NilV
            }
          case _ => error(s"type mismatch")
        }
        case h::t => interp(h,env,hand,hv =>
          makeArgL(t,avals:+hv ,fv)  
        )
      }
      interp(function, env, hand, fv =>
        makeArgL(arguments,List(),fv)
      )

    case Test(expression: Expr, typ: Type) => 
      interp(expression,env, hand, ev => 
        ev match {
          case IntV(value: BigInt) => typ match {
            case IntT => k(BooleanV(true))
            case _ => k(BooleanV(false))
          }
          case BooleanV(value: Boolean) => typ match {
            case BooleanT => k(BooleanV(true))
            case _ => k(BooleanV(false))
          }
          case TupleV(values: List[Value]) => typ match {
            case TupleT => k(BooleanV(true))
            case _ => k(BooleanV(false))
          }
          case NilV => typ match {
            case ListT => k(BooleanV(true))
            case _ => k(BooleanV(false))
          }
          case ConsV(head: Value, tail: Value) => typ match {
            case ListT => k(BooleanV(true))
            case _ => k(BooleanV(false))
          }
          case CloV(parameters: List[String], body: Expr, env: Env) => typ match {
            case FunctionT => 
              k(BooleanV(true))
            case _ => k(BooleanV(false))
          } 
          case ContV(continuation: Cont) => typ match {
            case FunctionT => 
              k(BooleanV(true))
            case _ => k(BooleanV(false))
          }
        }
      )
      
      case Throw(expression: Expr) => 
        interp(expression, env, hand, ev =>
          hand match 
          {
            case ExceptionH(eh: Expr, envh: Env, kh: Cont, hh: Handler) =>
              interp(eh,envh,hh, vh =>
                vh match {
                  case CloV(parameters: List[String], body: Expr, fenv: Env) => {
                    if(parameters.length != 1) error(s"Must have exactly one parameter")
                    parameters match {
                      case h::t => interp(body, fenv +(h->ev), hh, kh) 
                      case Nil => NilV
                    }
                  }
                  case ContV(kv: Cont) => 
                    kv(ev)
                  case _ => error(s"type mismatch")
                }
              )

            case NoH => error(s"There must be an exception handler")
          }  
        )
      
      case Try(expression: Expr, handler: Expr) => 
        val new_hand = ExceptionH(handler, env, k, hand)
        interp(expression, env, new_hand, k)
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

  def interp(expr: Expr): Value = interp(expr,Map(), NoH, x => x)

}
