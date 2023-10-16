package cs320

object Implementation extends Template {

  def typeCheck(e: Typed.Expr): Typed.Type = T.typeCheck(e)

  def interp(e: Untyped.Expr): Untyped.Value = U.interp(e)

  object T {
    import Typed._

    case class TypeScheme(t: Type, typeVars: List[VarT])

    case class TypeEnv(
      vars: Map[String,(TypeScheme,Boolean)] = Map(),
      typeDefs : Map[String, TypeDef] = Map()){
        def addTypeDef(x: String, tdef : TypeDef): TypeEnv =
          copy(typeDefs = typeDefs + (x->tdef))
        def addVar(x: String, t: TypeScheme, mut: Boolean): TypeEnv =
          copy(vars = vars + (x->(t,mut)))
        }

    def mustSame(l: Type, r: Type):Type =
      if(same(l,r)) l
      else error("not same")

    def same(l:Type, r: Type): Boolean = (l,r) match {
      case (ArrowT(p1s, r1),ArrowT(p2s, r2)) =>{
        listSame(p1s zip p2s, true) & same(r1,r2)
      }
      case (AppT(n1, targs1),AppT(n2, targs2))=>{
        listSame(targs1 zip targs2, true) & (n1 == n2) 
      }
      case (IntT, IntT) => true
      case (BooleanT, BooleanT) => true
      case (UnitT, UnitT) => true
      case (VarT(t1),VarT(t2)) =>t1 == t2 
      case _ => false
      
    }

    def listSame(l:List[(Type,Type)],b: Boolean):Boolean = l match{
      case Nil => b
      case h::t => {
        val (lb,rb) = h
        listSame(t,b & same(lb,rb))
      }
    }

    def typeSubstitute(t: Type, typeVars: List[VarT], targs: List[Type]):Type = {
      t match {
        case ArrowT(types: List[Type],rtype:Type) => {
          def makeList(types: List[Type], result: List[Type]): List[Type] = types match {
            case Nil => result
            case h::t => makeList(t, result :+ typeSubstitute(h, typeVars,targs))
          }
          val l = makeList(types,List())
          val r = typeSubstitute(rtype,typeVars,targs)
          ArrowT(l,r) 
        }
        case AppT(name: String, tvars:List[Type]) => {
          
          def makeList(tvars: List[Type], result: List[Type]): List[Type] = tvars match {
            case Nil => result
            case h::t=> {
              h match {
                case VarT(_) => {
                  val index = typeVars.indexOf(h)
                  if(index != -1) makeList(t, result :+ targs(index))
                  else makeList(t, result :+ h)
                }
                case typ@_ => {
                    makeList(t, result :+ typeSubstitute(typ,typeVars,targs))
                }
              }
            }
          }
          val l = makeList(tvars,List())
          AppT(name, l)
        }
        case v@VarT(name: String) => {
          val index = typeVars.indexOf(v)
          targs(index)
        }
        case _ => t
      }
    }

    def typeCheck(expr: Expr, tyEnv: TypeEnv): Type = expr match {

      case Id(name: String, targs: List[Type]) =>{
        listVaildCheck(targs,tyEnv)
        val typeScheme = tyEnv.vars.getOrElse(name,error(s"not in the type env"))
        if(targs.length != typeScheme._1.typeVars.length) error(s"length mismatch")
        if(targs.length == 0) typeScheme._1.t
        else typeSubstitute(typeScheme._1.t,typeScheme._1.typeVars,targs)
      }
      case IntE(value: BigInt) => IntT
      case BooleanE(value: Boolean) => BooleanT
      case UnitE => UnitT
      case Add(left: Expr, right: Expr) => (typeCheck(left,tyEnv),typeCheck(right,tyEnv)) match {
        case (IntT, IntT) => IntT
        case _ => error(s"type mismatch")
      }
      case Mul(left: Expr, right: Expr) => (typeCheck(left,tyEnv),typeCheck(right,tyEnv)) match {
        case (IntT, IntT) => IntT
        case _ => error(s"type mismatch")
      }
      case Div(left: Expr, right: Expr) => (typeCheck(left,tyEnv),typeCheck(right,tyEnv)) match {
        case (IntT, IntT) => IntT
        case _ => error(s"type mismatch")
      }
      case Mod(left: Expr, right: Expr) => (typeCheck(left,tyEnv),typeCheck(right,tyEnv)) match {
        case (IntT, IntT) => IntT
        case _ => error(s"type mismatch")
      }
      case Eq(left: Expr, right: Expr) => (typeCheck(left,tyEnv),typeCheck(right,tyEnv)) match {
        case (IntT, IntT) => BooleanT
        case _ => error(s"type mismatch")
      }
      case Lt(left: Expr, right: Expr) => (typeCheck(left,tyEnv),typeCheck(right,tyEnv)) match {
        case (IntT, IntT) => BooleanT
        case _ => error(s"type mismatch")
      }
      case Sequence(left: Expr, right: Expr)=>{
        validType(typeCheck(left,tyEnv),tyEnv)
        typeCheck(right,tyEnv)
      }
      case If(cond: Expr, texpr: Expr, fexpr: Expr)=>{
        mustSame(typeCheck(cond,tyEnv),BooleanT)
        mustSame(typeCheck(texpr,tyEnv),typeCheck(fexpr,tyEnv))
      }
      case Val(mut: Boolean, name: String, typ: Option[Type], e: Expr, b: Expr) => typ match {
        case Some(v) =>{
          val tp = validType(v, tyEnv)
          val t1 = typeCheck(e, tyEnv)
          mustSame(tp,t1)
          typeCheck(b,tyEnv.addVar(name,TypeScheme(t1,List()),mut))
        }
        case None => {
          val t1 = typeCheck(e, tyEnv)
          typeCheck(b,tyEnv.addVar(name,TypeScheme(t1,List()),mut))
        }

      }
      case RecBinds(defs: List[RecDef], body: Expr) => {  
        
       def makeNewTyEnv(defs: List[RecDef], tyEnv: TypeEnv): TypeEnv = defs match {
         case Nil => tyEnv
         case h::t => h match {
          case Lazy(name: String, typ: Type, expr: Expr) => {
            validType(typ,tyEnv)
            val ntyEnv = tyEnv.addVar(name, TypeScheme(typ,List()),false)
            val etype = typeCheck(expr,ntyEnv)
            mustSame(typ,etype)
            makeNewTyEnv(t,ntyEnv) 
          }
          case RecFun(name: String, tparams: List[String], params: List[(String, Type)], rtype: Type, body: Expr) => {
            val (strings, types) = params.unzip
            val tvars = tparams.map(x => VarT(x))
            makeNewTyEnv(t, tyEnv.addVar(name,TypeScheme(ArrowT(types,rtype),tvars),false))
          }
          case td@TypeDef(name: String, tparams: List[String], variants: List[Variant]) => {
            if(tyEnv.typeDefs.contains(name)) error(s"must not be in the domain")
            val newTyEnv = tyEnv.addTypeDef(name, td)
            val tvars = tparams.map(x => VarT(x))

            def addMappings(variants: List[Variant], typeEnv : TypeEnv): TypeEnv = variants match {
              case Nil => typeEnv 
              case h::t => {
                if(h.params.length == 0){
                  addMappings(t, typeEnv.addVar(h.name, TypeScheme(AppT(name, tvars),tvars) ,false))
                }
                else{
                  addMappings(t, typeEnv.addVar(h.name,TypeScheme(ArrowT(h.params,AppT(name, tvars)),tvars) ,false))
                }
              }
            }     
            makeNewTyEnv(t, addMappings(variants,newTyEnv))
          }
         }
       }

       def validAll(defs: List[RecDef], tyEnv: TypeEnv): Unit = defs match{
        case Nil => ()
        case h::t => h match {
          case RecFun(name: String, tparams: List[String], params: List[(String, Type)], rtype: Type, body: Expr) => {
            def addtypeParams(tvars: List[(String,Type)], typeEnv: TypeEnv): TypeEnv= tvars match {
              case Nil => typeEnv
              case h::t =>{
                  val (name,tvar) = h
                  addtypeParams(t, typeEnv.addVar(name, TypeScheme(tvar,List()),false))
              }              
            }
            def addMappings(params: List[(String, Type)], typeEnv : TypeEnv): TypeEnv = params match {
              case Nil => typeEnv 
              case h::t => {
                val (name, typ) = h
                addMappings(t, typeEnv.addVar(name, TypeScheme(typ,List()),false))
              }
            }
            val tvars = tparams.map(x => VarT(x))
            val paramAddedTyEnv = addtypeParams(tparams zip tvars,tyEnv)
            val ntyEnv = addMappings(params, paramAddedTyEnv)
            mustSame(rtype, typeCheck(body,ntyEnv))
            validAll(t, tyEnv)
          }
          case td@TypeDef(name: String, tparams: List[String], variants: List[Variant]) =>{
            def addtypeParams(tvars: List[(String,Type)], typeEnv: TypeEnv): TypeEnv= tvars match {
              case Nil => typeEnv
              case h::t =>{
                  val (name,tvar) = h
                  addtypeParams(t, typeEnv.addVar(name, TypeScheme(tvar,List()),false))
              }              
            }
            val tvars = tparams.map(x => VarT(x))
            val paramAddedTyEnv = addtypeParams(tparams zip tvars,tyEnv)
            for(a <- variants){
              listVaildCheck(a.params, paramAddedTyEnv)
            }
            validAll(t, tyEnv)
          }
          case _ => ()
        }
       }
       val newtyEnv = makeNewTyEnv(defs,tyEnv)
       validAll(defs,newtyEnv)
       val result = typeCheck(body, newtyEnv)
       validType(result, tyEnv)
       result
      }
      case Fun(params: List[(String, Type)], body: Expr) => {
        def makeNewTyEnv(params: List[(String, Type)], tyEnv: TypeEnv): TypeEnv = params match {
          case Nil => tyEnv
          case h::t => {
            val (name,ty) = (h._1, h._2)
            makeNewTyEnv(t,tyEnv.addVar(name, TypeScheme(ty,List()),false))
          }
        }
        val (names, types) = params.unzip
        listVaildCheck(types,tyEnv)
        val returnT = typeCheck(body,makeNewTyEnv(params, tyEnv)) 
        ArrowT(types,returnT)
      }
      case Assign(name: String, expr: Expr) => {
        val typeScheme = tyEnv.vars.getOrElse(name,error(s"not in the type env"))
        if(typeScheme._1.typeVars.length != 0) error(s"length mismatch")
        if(!typeScheme._2) error(s"mut must be true")
        mustSame(typeScheme._1.t , typeCheck(expr,tyEnv))
        UnitT
      }
      case App(fun: Expr, args: List[Expr]) => {
        typeCheck(fun, tyEnv) match {
          case ArrowT(ptypes: List[Type], rtype: Type) =>
            if(args.length != ptypes.length) error(s"length mismatch")
            def checkSame(l : List[(Type,Expr)]): Unit = l match {
              case Nil => ()
              case h::t => {
                val (typ,expr) = h
               
                mustSame(typ, typeCheck(expr,tyEnv))
              }
            }
            
            checkSame(ptypes zip args)
            rtype
          case _ => error(s"type mismatch")
        }
      }
      
      case Match(expr: Expr, cases: List[Case]) => {
        typeCheck(expr,tyEnv) match {
          case AppT(name: String, targs: List[Type]) => {
            val typeDef = tyEnv.typeDefs.getOrElse(name,error(s"not in the type env"))
            if(typeDef.tparams.length != targs.length) error(s"length mismatch")
            if(typeDef.variants.length != cases.length) error(s"length mismatch")
            
            def typeCheckCases(cases:List[Case], l : List[Type]): List[Type] = cases match {
              case Nil => l
              case h::t =>{
                typeCheckCases(t, l :+ typeCheckCase(h, typeDef.variants,typeDef.tparams,targs,tyEnv))
              }
            }
            val tlist = typeCheckCases(cases,List())
            val t0 = tlist(0)
            for(t <- tlist){
              mustSame(t,t0)
            }
            t0
         }
         case _ => error(s"type mismatch")
        }
      }
    }
      def typeCheckCase(c: Case, variants: List[Variant],tparams: List[String], targs: List[Type], tyEnv: TypeEnv):Type = {
          if(tparams.length != targs.length) error(s"length mismatch")
          val namelist = variants.map(x => x.name)
          val index =namelist.indexOf(c.variant)
          val w = variants(index)
          if(w.params.length != c.names.length) error(s"length mistmatch")
          val tvars = tparams.map(x => VarT(x))
          def makeNewTyEnv(types: List[(String,Type)], tenv: TypeEnv):TypeEnv = types match {
            case Nil => tenv
            case h::t => {
              val (x,typ) = h
              val nt = typeSubstitute(typ, tvars, targs)
              makeNewTyEnv(t, tenv.addVar(x,TypeScheme(nt,List()),false))
            }
          }
          typeCheck(c.body, makeNewTyEnv(c.names zip w.params, tyEnv))
      }
      
      def validType(ty: Type, tyEnv: TypeEnv): Type = ty match {
        case AppT(name: String, targs: List[Type]) =>{
          listVaildCheck(targs, tyEnv)
          val tydef = tyEnv.typeDefs.getOrElse(name, error(s"not in the type env"))
          if(targs.length != tydef.tparams.length) error(s"length mismatch")
          ty
        }
        case VarT(name: String) => {
          if(tyEnv.vars.contains(name))ty
          else error(s"not in the type env")
        }
        case IntT => ty
        case BooleanT => ty
        case UnitT => ty
        case ArrowT(ptypes: List[Type], rtype: Type) => {
          listVaildCheck(ptypes,tyEnv)
          validType(rtype,tyEnv)
          ty
        }
      }

      def listVaildCheck(tyList: List[Type], tyEnv: TypeEnv): Unit = tyList match {
        case Nil => ()
        case h::t => {
          validType(h,tyEnv)
          listVaildCheck(t,tyEnv)
        }
      }

      def typeCheck(expr: Expr): Type = typeCheck(expr, TypeEnv())
  }
  
  object U {
    import Untyped._

    type Sto = Map[Addr, Value]

    def interp(expr: Expr, env: Env, sto: Sto): (Value,Sto) = expr match {
      case Id(name: String) => {
        val a = env.getOrElse(name, error("not in environment"))
        val v = sto.getOrElse(a, error("not in store"))
        v match {
          case ExprV(expr: Untyped.Expr, env: Env) => {
            val (v1,s1) = interp(expr,env,sto)
            (v1, s1 + (a->v1))
          }
          case _ => (v,sto)
        }
      }
      case IntE(value: BigInt) => (IntV(value),sto)
      case BooleanE(value: Boolean) => (BooleanV(value),sto)
      case UnitE => (UnitV,sto)
      case Add(left: Expr, right: Expr) => {
        val (lv, ls) = interp(left,env,sto)
        val (rv, rs) = interp(right,env,ls)
        (IntVadd(lv,rv),rs)
      } 
      case Mul(left: Expr, right: Expr) => {
        val (lv, ls) = interp(left,env,sto)
        val (rv, rs) = interp(right,env,ls)
        (IntVmul(lv,rv),rs)
      } 
      case Div(left: Expr, right: Expr) => {
        val (lv, ls) = interp(left,env,sto)
        val (rv, rs) = interp(right,env,ls)
        (IntVdiv(lv,rv),rs)
      } 
      case Mod(left: Expr, right: Expr) => {
        val (lv, ls) = interp(left,env,sto)
        val (rv, rs) = interp(right,env,ls)
        (IntVmod(lv,rv),rs)
      } 
      case Eq(left: Expr, right: Expr) => {
        val (lv, ls) = interp(left,env,sto)
        val (rv, rs) = interp(right,env,ls)
        (IntVeq(lv,rv),rs)
      }
      case Lt(left: Expr, right: Expr) => {
        val (lv, ls) = interp(left,env,sto)
        val (rv, rs) = interp(right,env,ls)
        (IntVlt(lv,rv),rs)
      }
      case Sequence(left: Expr, right: Expr) => {
        val (lv, ls) = interp(left,env,sto)
        interp(right,env,ls)
      }
      case If(cond: Expr, texpr: Expr, fexpr: Expr) => {
        val (v1,s1) = interp(cond,env,sto)
        v1 match {
          case BooleanV(bool) => {
            if(bool) interp(texpr,env,s1)
            else interp(fexpr,env,s1)
          }
          case _ => error(s"type mismatch")
        }
      }
      case Val(name: String, expr: Expr, body: Expr) => {
        val (v1,s1) = interp(expr,env,sto)
        val a = malloc(s1)
        interp(body, env+(name->a),s1+(a->v1))
      }
      case RecBinds(defs: List[RecDef], body: Expr) => {

        def makeNewEnv(defs: List[RecDef], env: Env, sto: Sto): Env = defs match {
          case Nil => env
          case h::t => h match{
            case Lazy(name: String, expr: Expr) => {
              val addr = malloc(sto)
              makeNewEnv(t,env +(name->addr),sto+(addr->UnitV))
            }
            case RecFun(name: String, params: List[String], body: Expr) => {
              val addr = malloc(sto)
              makeNewEnv(t,env + (name->addr),sto+(addr->UnitV))
            }
            case TypeDef(variants: List[Variant]) => {
              def addMappings(l: List[Variant], env: Env, sto: Sto): (Env,Sto) = l match {
                case Nil => {
                  (env,sto)
                }
                case h::t => {
                  if(h.empty){
                    val addr = malloc(sto)
                    addMappings(t, env+(h.name->addr),sto+(addr->UnitV)) // 일단 임시로 UnitV
                  }
                  else{
                    val addr = malloc(sto)
                    addMappings(t, env+(h.name->addr),sto+(addr->UnitV))
                  }
                }
              }
              val (nenv,nsto) = addMappings(variants,env,sto)
              makeNewEnv(t,nenv,nsto) 
            }
          } 
        }

        def makeNewSto(defs: List[RecDef], sto: Sto, env:Env): Sto = defs match {
          case Nil => sto
          case h::t => h match {
            case Lazy(name: String, expr: Expr) => {
              val addr = env.getOrElse(name,error(s"not in environment"))
              makeNewSto(t,sto + (addr -> ExprV(expr, env)),env)
            }
            case RecFun(name: String, params: List[String], body: Expr) => {
              val addr = env.getOrElse(name,error(s"not in environment"))
              makeNewSto(t,sto + (addr-> CloV(params, body,env)),env)
            }
            case TypeDef(variants: List[Variant]) => {
              def addMappings(l: List[Variant], env: Env, sto: Sto): Sto = l match {
                case Nil => sto
                case h::t => {
                  if(h.empty){
                    val addr = env.getOrElse(h.name,error(s"not in environment"))
                    addMappings(t, env,sto+(addr->VariantV(h.name,List())))
                  }
                  else{
                    val addr = env.getOrElse(h.name,error(s"not in environment"))
                    addMappings(t, env,sto+(addr->ConstructorV(h.name)))
                  }
                }
              }
              makeNewSto(t,addMappings(variants,env,sto),env)
              
            }
          }
        }
        val nenv = makeNewEnv(defs,env,sto)
        val nsto = makeNewSto(defs,sto,nenv)
        interp(body, nenv, nsto)
      }
      case Fun(params: List[String], body: Expr) => (CloV(params, body,env),sto)
      case Assign(name: String, expr: Expr) => {
          val addr = env.getOrElse(name,error(s"not in environment")) 
          val (v1,s1) = interp(expr, env, sto)
          (UnitV, s1 + (addr->v1))
      }
      case App(fun: Expr, args: List[Expr]) => {
        def evaluateAll(exprs: List[Expr],l: List[Value],sto: Sto): (List[Value], Sto) = exprs match {
          case Nil => (l,sto)
          case h::t => {
            val (v,s) = interp(h, env, sto)
            evaluateAll(t,l:+v,s)
          }
        }
        def makeNewEnvSto ( l:List[(String,Value)],env: Env, sto: Sto): (Env,Sto) = l match {
          case Nil => (env,sto)
          case h::t => {
             val (str, v) = h
             val addr = malloc(sto)
             makeNewEnvSto(t, env + (str->addr), sto + (addr->v))
          }
        }
        val (v,s) = interp(fun,env,sto)
        val (vl,ns) = evaluateAll(args,List(),s)
        v match {
          case CloV(params: List[String], body: Untyped.Expr, fenv: Env) => {
            if(args.length != params.length) error(s"length mismatch")
            val (e,s) = makeNewEnvSto(params zip vl,fenv, ns)
            interp(body,e,s)
          }
          case ConstructorV(name: String) => {
            (VariantV(name, vl),ns)
          }
          case _ => error("type mismatch")
        }
      }
      case Match(expr: Expr, cases: List[Case]) => {
        val (v,s) = interp(expr, env, sto)
        v match {
          case VariantV(name: String, values: List[Value])=>{
            val namelist = cases.map(x => x.variant)
            val index =namelist.indexOf(name)
            val c = cases(index)
            if(values.length != c.names.length) error(s"length mistmatch")
            def makeNewEnvSto (l:List[(String,Value)],env: Env, sto: Sto): (Env,Sto) = l match {
              case Nil => (env,sto)
              case h::t => {
                val (str,v) = h
                val addr = malloc(sto)
                makeNewEnvSto(t, env + (str->addr), sto + (addr->v))
              }
            }
            val (e,s) = makeNewEnvSto(c.names zip values, env, sto)
            interp(c.body, e,s)
          }
          case _ => error(s"type mismatch")
        }
      }
    }

    def IntVadd(left: Value , right: Value): Value = (left,right) match {
      case (IntV(x),IntV(y)) => IntV(x + y)
      case _ => error(s"type mismatch")
    }
    def IntVmul(left: Value , right: Value): Value = (left,right) match {
      case (IntV(x),IntV(y)) => IntV(x * y)
      case _ => error(s"type mismatch")
    }
    def IntVdiv(left: Value , right: Value): Value = (left,right) match {
      case (IntV(x),IntV(y)) =>{
        if(y == 0) error(s"divide by zero")
        else IntV(x / y)
      } 
      case _ => error(s"type mismatch")
    }
    def IntVmod(left: Value , right: Value): Value = (left,right) match {
      case (IntV(x),IntV(y)) => {
        if(y == 0) error(s"divide by zero")
        else IntV(x % y)
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
    def interp(expr: Expr): Value = interp(expr, Map(),Map())._1
    private def malloc(sto: Sto): Addr = sto.keys.maxOption.map(_ + 1).getOrElse(0)
  }
}