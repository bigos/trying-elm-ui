(() => {
  // output/Data.Show/foreign.js
  var showIntImpl = function(n) {
    return n.toString();
  };

  // output/Data.Show/index.js
  var showInt = {
    show: showIntImpl
  };
  var show = function(dict) {
    return dict.show;
  };

  // output/Data.Unit/foreign.js
  var unit = void 0;

  // output/Data.Unit/index.js
  var showUnit = {
    show: function(v) {
      return "unit";
    }
  };

  // output/Data.Bounded/foreign.js
  var topChar = String.fromCharCode(65535);
  var bottomChar = String.fromCharCode(0);
  var topNumber = Number.POSITIVE_INFINITY;
  var bottomNumber = Number.NEGATIVE_INFINITY;

  // output/Data.Functor/foreign.js
  var arrayMap = function(f) {
    return function(arr) {
      var l = arr.length;
      var result = new Array(l);
      for (var i = 0; i < l; i++) {
        result[i] = f(arr[i]);
      }
      return result;
    };
  };

  // output/Control.Semigroupoid/index.js
  var semigroupoidFn = {
    compose: function(f) {
      return function(g) {
        return function(x) {
          return f(g(x));
        };
      };
    }
  };

  // output/Control.Category/index.js
  var identity = function(dict) {
    return dict.identity;
  };
  var categoryFn = {
    identity: function(x) {
      return x;
    },
    Semigroupoid0: function() {
      return semigroupoidFn;
    }
  };

  // output/Data.Function/index.js
  var flip = function(f) {
    return function(b) {
      return function(a) {
        return f(a)(b);
      };
    };
  };
  var $$const = function(a) {
    return function(v) {
      return a;
    };
  };

  // output/Data.Functor/index.js
  var map = function(dict) {
    return dict.map;
  };
  var $$void = function(dictFunctor) {
    return map(dictFunctor)($$const(unit));
  };
  var functorArray = {
    map: arrayMap
  };

  // output/Data.Semigroup/index.js
  var append = function(dict) {
    return dict.append;
  };

  // output/Data.Monoid/index.js
  var mempty = function(dict) {
    return dict.mempty;
  };

  // output/Data.Tuple/index.js
  var Tuple = /* @__PURE__ */ function() {
    function Tuple2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Tuple2.create = function(value0) {
      return function(value1) {
        return new Tuple2(value0, value1);
      };
    };
    return Tuple2;
  }();

  // output/Control.Apply/foreign.js
  var arrayApply = function(fs) {
    return function(xs) {
      var l = fs.length;
      var k = xs.length;
      var result = new Array(l * k);
      var n = 0;
      for (var i = 0; i < l; i++) {
        var f = fs[i];
        for (var j = 0; j < k; j++) {
          result[n++] = f(xs[j]);
        }
      }
      return result;
    };
  };

  // output/Control.Apply/index.js
  var identity2 = /* @__PURE__ */ identity(categoryFn);
  var applyArray = {
    apply: arrayApply,
    Functor0: function() {
      return functorArray;
    }
  };
  var apply = function(dict) {
    return dict.apply;
  };
  var applySecond = function(dictApply) {
    var apply1 = apply(dictApply);
    var map3 = map(dictApply.Functor0());
    return function(a) {
      return function(b) {
        return apply1(map3($$const(identity2))(a))(b);
      };
    };
  };

  // output/Control.Applicative/index.js
  var pure = function(dict) {
    return dict.pure;
  };
  var when = function(dictApplicative) {
    var pure1 = pure(dictApplicative);
    return function(v) {
      return function(v1) {
        if (v) {
          return v1;
        }
        ;
        if (!v) {
          return pure1(unit);
        }
        ;
        throw new Error("Failed pattern match at Control.Applicative (line 63, column 1 - line 63, column 63): " + [v.constructor.name, v1.constructor.name]);
      };
    };
  };
  var liftA1 = function(dictApplicative) {
    var apply2 = apply(dictApplicative.Apply0());
    var pure1 = pure(dictApplicative);
    return function(f) {
      return function(a) {
        return apply2(pure1(f))(a);
      };
    };
  };

  // output/Data.Maybe/index.js
  var Nothing = /* @__PURE__ */ function() {
    function Nothing2() {
    }
    ;
    Nothing2.value = new Nothing2();
    return Nothing2;
  }();
  var Just = /* @__PURE__ */ function() {
    function Just2(value0) {
      this.value0 = value0;
    }
    ;
    Just2.create = function(value0) {
      return new Just2(value0);
    };
    return Just2;
  }();
  var functorMaybe = {
    map: function(v) {
      return function(v1) {
        if (v1 instanceof Just) {
          return new Just(v(v1.value0));
        }
        ;
        return Nothing.value;
      };
    }
  };

  // output/Data.Either/index.js
  var Left = /* @__PURE__ */ function() {
    function Left2(value0) {
      this.value0 = value0;
    }
    ;
    Left2.create = function(value0) {
      return new Left2(value0);
    };
    return Left2;
  }();
  var Right = /* @__PURE__ */ function() {
    function Right2(value0) {
      this.value0 = value0;
    }
    ;
    Right2.create = function(value0) {
      return new Right2(value0);
    };
    return Right2;
  }();

  // output/Data.Foldable/foreign.js
  var foldrArray = function(f) {
    return function(init4) {
      return function(xs) {
        var acc = init4;
        var len = xs.length;
        for (var i = len - 1; i >= 0; i--) {
          acc = f(xs[i])(acc);
        }
        return acc;
      };
    };
  };
  var foldlArray = function(f) {
    return function(init4) {
      return function(xs) {
        var acc = init4;
        var len = xs.length;
        for (var i = 0; i < len; i++) {
          acc = f(acc)(xs[i]);
        }
        return acc;
      };
    };
  };

  // output/Control.Bind/foreign.js
  var arrayBind = function(arr) {
    return function(f) {
      var result = [];
      for (var i = 0, l = arr.length; i < l; i++) {
        Array.prototype.push.apply(result, f(arr[i]));
      }
      return result;
    };
  };

  // output/Control.Bind/index.js
  var bindArray = {
    bind: arrayBind,
    Apply0: function() {
      return applyArray;
    }
  };
  var bind = function(dict) {
    return dict.bind;
  };
  var bindFlipped = function(dictBind) {
    return flip(bind(dictBind));
  };

  // output/Unsafe.Coerce/foreign.js
  var unsafeCoerce2 = function(x) {
    return x;
  };

  // output/Data.Foldable/index.js
  var foldr = function(dict) {
    return dict.foldr;
  };
  var traverse_ = function(dictApplicative) {
    var applySecond2 = applySecond(dictApplicative.Apply0());
    var pure4 = pure(dictApplicative);
    return function(dictFoldable) {
      var foldr2 = foldr(dictFoldable);
      return function(f) {
        return foldr2(function($454) {
          return applySecond2(f($454));
        })(pure4(unit));
      };
    };
  };
  var for_ = function(dictApplicative) {
    var traverse_1 = traverse_(dictApplicative);
    return function(dictFoldable) {
      return flip(traverse_1(dictFoldable));
    };
  };
  var foldMapDefaultR = function(dictFoldable) {
    var foldr2 = foldr(dictFoldable);
    return function(dictMonoid) {
      var append2 = append(dictMonoid.Semigroup0());
      var mempty2 = mempty(dictMonoid);
      return function(f) {
        return foldr2(function(x) {
          return function(acc) {
            return append2(f(x))(acc);
          };
        })(mempty2);
      };
    };
  };
  var foldableArray = {
    foldr: foldrArray,
    foldl: foldlArray,
    foldMap: function(dictMonoid) {
      return foldMapDefaultR(foldableArray)(dictMonoid);
    }
  };

  // output/Effect/foreign.js
  var pureE = function(a) {
    return function() {
      return a;
    };
  };
  var bindE = function(a) {
    return function(f) {
      return function() {
        return f(a())();
      };
    };
  };

  // output/Control.Monad/index.js
  var ap = function(dictMonad) {
    var bind2 = bind(dictMonad.Bind1());
    var pure4 = pure(dictMonad.Applicative0());
    return function(f) {
      return function(a) {
        return bind2(f)(function(f$prime) {
          return bind2(a)(function(a$prime) {
            return pure4(f$prime(a$prime));
          });
        });
      };
    };
  };

  // output/Effect/index.js
  var $runtime_lazy = function(name2, moduleName, init4) {
    var state2 = 0;
    var val;
    return function(lineNumber) {
      if (state2 === 2) return val;
      if (state2 === 1) throw new ReferenceError(name2 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state2 = 1;
      val = init4();
      state2 = 2;
      return val;
    };
  };
  var monadEffect = {
    Applicative0: function() {
      return applicativeEffect;
    },
    Bind1: function() {
      return bindEffect;
    }
  };
  var bindEffect = {
    bind: bindE,
    Apply0: function() {
      return $lazy_applyEffect(0);
    }
  };
  var applicativeEffect = {
    pure: pureE,
    Apply0: function() {
      return $lazy_applyEffect(0);
    }
  };
  var $lazy_functorEffect = /* @__PURE__ */ $runtime_lazy("functorEffect", "Effect", function() {
    return {
      map: liftA1(applicativeEffect)
    };
  });
  var $lazy_applyEffect = /* @__PURE__ */ $runtime_lazy("applyEffect", "Effect", function() {
    return {
      apply: ap(monadEffect),
      Functor0: function() {
        return $lazy_functorEffect(0);
      }
    };
  });
  var functorEffect = /* @__PURE__ */ $lazy_functorEffect(20);

  // output/Effect.Aff/foreign.js
  var Aff = function() {
    var EMPTY = {};
    var PURE = "Pure";
    var THROW = "Throw";
    var CATCH = "Catch";
    var SYNC = "Sync";
    var ASYNC = "Async";
    var BIND = "Bind";
    var BRACKET = "Bracket";
    var FORK = "Fork";
    var SEQ = "Sequential";
    var MAP = "Map";
    var APPLY = "Apply";
    var ALT = "Alt";
    var CONS = "Cons";
    var RESUME = "Resume";
    var RELEASE = "Release";
    var FINALIZER = "Finalizer";
    var FINALIZED = "Finalized";
    var FORKED = "Forked";
    var FIBER = "Fiber";
    var THUNK = "Thunk";
    function Aff2(tag, _1, _2, _3) {
      this.tag = tag;
      this._1 = _1;
      this._2 = _2;
      this._3 = _3;
    }
    function AffCtr(tag) {
      var fn = function(_1, _2, _3) {
        return new Aff2(tag, _1, _2, _3);
      };
      fn.tag = tag;
      return fn;
    }
    function nonCanceler(error3) {
      return new Aff2(PURE, void 0);
    }
    function runEff(eff) {
      try {
        eff();
      } catch (error3) {
        setTimeout(function() {
          throw error3;
        }, 0);
      }
    }
    function runSync(left, right, eff) {
      try {
        return right(eff());
      } catch (error3) {
        return left(error3);
      }
    }
    function runAsync(left, eff, k) {
      try {
        return eff(k)();
      } catch (error3) {
        k(left(error3))();
        return nonCanceler;
      }
    }
    var Scheduler = function() {
      var limit = 1024;
      var size3 = 0;
      var ix = 0;
      var queue = new Array(limit);
      var draining = false;
      function drain() {
        var thunk;
        draining = true;
        while (size3 !== 0) {
          size3--;
          thunk = queue[ix];
          queue[ix] = void 0;
          ix = (ix + 1) % limit;
          thunk();
        }
        draining = false;
      }
      return {
        isDraining: function() {
          return draining;
        },
        enqueue: function(cb) {
          var i, tmp;
          if (size3 === limit) {
            tmp = draining;
            drain();
            draining = tmp;
          }
          queue[(ix + size3) % limit] = cb;
          size3++;
          if (!draining) {
            drain();
          }
        }
      };
    }();
    function Supervisor(util) {
      var fibers = {};
      var fiberId = 0;
      var count = 0;
      return {
        register: function(fiber) {
          var fid = fiberId++;
          fiber.onComplete({
            rethrow: true,
            handler: function(result) {
              return function() {
                count--;
                delete fibers[fid];
              };
            }
          })();
          fibers[fid] = fiber;
          count++;
        },
        isEmpty: function() {
          return count === 0;
        },
        killAll: function(killError, cb) {
          return function() {
            if (count === 0) {
              return cb();
            }
            var killCount = 0;
            var kills = {};
            function kill(fid) {
              kills[fid] = fibers[fid].kill(killError, function(result) {
                return function() {
                  delete kills[fid];
                  killCount--;
                  if (util.isLeft(result) && util.fromLeft(result)) {
                    setTimeout(function() {
                      throw util.fromLeft(result);
                    }, 0);
                  }
                  if (killCount === 0) {
                    cb();
                  }
                };
              })();
            }
            for (var k in fibers) {
              if (fibers.hasOwnProperty(k)) {
                killCount++;
                kill(k);
              }
            }
            fibers = {};
            fiberId = 0;
            count = 0;
            return function(error3) {
              return new Aff2(SYNC, function() {
                for (var k2 in kills) {
                  if (kills.hasOwnProperty(k2)) {
                    kills[k2]();
                  }
                }
              });
            };
          };
        }
      };
    }
    var SUSPENDED = 0;
    var CONTINUE = 1;
    var STEP_BIND = 2;
    var STEP_RESULT = 3;
    var PENDING = 4;
    var RETURN = 5;
    var COMPLETED = 6;
    function Fiber(util, supervisor, aff) {
      var runTick = 0;
      var status = SUSPENDED;
      var step2 = aff;
      var fail = null;
      var interrupt = null;
      var bhead = null;
      var btail = null;
      var attempts = null;
      var bracketCount = 0;
      var joinId = 0;
      var joins = null;
      var rethrow = true;
      function run4(localRunTick) {
        var tmp, result, attempt;
        while (true) {
          tmp = null;
          result = null;
          attempt = null;
          switch (status) {
            case STEP_BIND:
              status = CONTINUE;
              try {
                step2 = bhead(step2);
                if (btail === null) {
                  bhead = null;
                } else {
                  bhead = btail._1;
                  btail = btail._2;
                }
              } catch (e) {
                status = RETURN;
                fail = util.left(e);
                step2 = null;
              }
              break;
            case STEP_RESULT:
              if (util.isLeft(step2)) {
                status = RETURN;
                fail = step2;
                step2 = null;
              } else if (bhead === null) {
                status = RETURN;
              } else {
                status = STEP_BIND;
                step2 = util.fromRight(step2);
              }
              break;
            case CONTINUE:
              switch (step2.tag) {
                case BIND:
                  if (bhead) {
                    btail = new Aff2(CONS, bhead, btail);
                  }
                  bhead = step2._2;
                  status = CONTINUE;
                  step2 = step2._1;
                  break;
                case PURE:
                  if (bhead === null) {
                    status = RETURN;
                    step2 = util.right(step2._1);
                  } else {
                    status = STEP_BIND;
                    step2 = step2._1;
                  }
                  break;
                case SYNC:
                  status = STEP_RESULT;
                  step2 = runSync(util.left, util.right, step2._1);
                  break;
                case ASYNC:
                  status = PENDING;
                  step2 = runAsync(util.left, step2._1, function(result2) {
                    return function() {
                      if (runTick !== localRunTick) {
                        return;
                      }
                      runTick++;
                      Scheduler.enqueue(function() {
                        if (runTick !== localRunTick + 1) {
                          return;
                        }
                        status = STEP_RESULT;
                        step2 = result2;
                        run4(runTick);
                      });
                    };
                  });
                  return;
                case THROW:
                  status = RETURN;
                  fail = util.left(step2._1);
                  step2 = null;
                  break;
                // Enqueue the Catch so that we can call the error handler later on
                // in case of an exception.
                case CATCH:
                  if (bhead === null) {
                    attempts = new Aff2(CONS, step2, attempts, interrupt);
                  } else {
                    attempts = new Aff2(CONS, step2, new Aff2(CONS, new Aff2(RESUME, bhead, btail), attempts, interrupt), interrupt);
                  }
                  bhead = null;
                  btail = null;
                  status = CONTINUE;
                  step2 = step2._1;
                  break;
                // Enqueue the Bracket so that we can call the appropriate handlers
                // after resource acquisition.
                case BRACKET:
                  bracketCount++;
                  if (bhead === null) {
                    attempts = new Aff2(CONS, step2, attempts, interrupt);
                  } else {
                    attempts = new Aff2(CONS, step2, new Aff2(CONS, new Aff2(RESUME, bhead, btail), attempts, interrupt), interrupt);
                  }
                  bhead = null;
                  btail = null;
                  status = CONTINUE;
                  step2 = step2._1;
                  break;
                case FORK:
                  status = STEP_RESULT;
                  tmp = Fiber(util, supervisor, step2._2);
                  if (supervisor) {
                    supervisor.register(tmp);
                  }
                  if (step2._1) {
                    tmp.run();
                  }
                  step2 = util.right(tmp);
                  break;
                case SEQ:
                  status = CONTINUE;
                  step2 = sequential2(util, supervisor, step2._1);
                  break;
              }
              break;
            case RETURN:
              bhead = null;
              btail = null;
              if (attempts === null) {
                status = COMPLETED;
                step2 = interrupt || fail || step2;
              } else {
                tmp = attempts._3;
                attempt = attempts._1;
                attempts = attempts._2;
                switch (attempt.tag) {
                  // We cannot recover from an unmasked interrupt. Otherwise we should
                  // continue stepping, or run the exception handler if an exception
                  // was raised.
                  case CATCH:
                    if (interrupt && interrupt !== tmp && bracketCount === 0) {
                      status = RETURN;
                    } else if (fail) {
                      status = CONTINUE;
                      step2 = attempt._2(util.fromLeft(fail));
                      fail = null;
                    }
                    break;
                  // We cannot resume from an unmasked interrupt or exception.
                  case RESUME:
                    if (interrupt && interrupt !== tmp && bracketCount === 0 || fail) {
                      status = RETURN;
                    } else {
                      bhead = attempt._1;
                      btail = attempt._2;
                      status = STEP_BIND;
                      step2 = util.fromRight(step2);
                    }
                    break;
                  // If we have a bracket, we should enqueue the handlers,
                  // and continue with the success branch only if the fiber has
                  // not been interrupted. If the bracket acquisition failed, we
                  // should not run either.
                  case BRACKET:
                    bracketCount--;
                    if (fail === null) {
                      result = util.fromRight(step2);
                      attempts = new Aff2(CONS, new Aff2(RELEASE, attempt._2, result), attempts, tmp);
                      if (interrupt === tmp || bracketCount > 0) {
                        status = CONTINUE;
                        step2 = attempt._3(result);
                      }
                    }
                    break;
                  // Enqueue the appropriate handler. We increase the bracket count
                  // because it should not be cancelled.
                  case RELEASE:
                    attempts = new Aff2(CONS, new Aff2(FINALIZED, step2, fail), attempts, interrupt);
                    status = CONTINUE;
                    if (interrupt && interrupt !== tmp && bracketCount === 0) {
                      step2 = attempt._1.killed(util.fromLeft(interrupt))(attempt._2);
                    } else if (fail) {
                      step2 = attempt._1.failed(util.fromLeft(fail))(attempt._2);
                    } else {
                      step2 = attempt._1.completed(util.fromRight(step2))(attempt._2);
                    }
                    fail = null;
                    bracketCount++;
                    break;
                  case FINALIZER:
                    bracketCount++;
                    attempts = new Aff2(CONS, new Aff2(FINALIZED, step2, fail), attempts, interrupt);
                    status = CONTINUE;
                    step2 = attempt._1;
                    break;
                  case FINALIZED:
                    bracketCount--;
                    status = RETURN;
                    step2 = attempt._1;
                    fail = attempt._2;
                    break;
                }
              }
              break;
            case COMPLETED:
              for (var k in joins) {
                if (joins.hasOwnProperty(k)) {
                  rethrow = rethrow && joins[k].rethrow;
                  runEff(joins[k].handler(step2));
                }
              }
              joins = null;
              if (interrupt && fail) {
                setTimeout(function() {
                  throw util.fromLeft(fail);
                }, 0);
              } else if (util.isLeft(step2) && rethrow) {
                setTimeout(function() {
                  if (rethrow) {
                    throw util.fromLeft(step2);
                  }
                }, 0);
              }
              return;
            case SUSPENDED:
              status = CONTINUE;
              break;
            case PENDING:
              return;
          }
        }
      }
      function onComplete(join3) {
        return function() {
          if (status === COMPLETED) {
            rethrow = rethrow && join3.rethrow;
            join3.handler(step2)();
            return function() {
            };
          }
          var jid = joinId++;
          joins = joins || {};
          joins[jid] = join3;
          return function() {
            if (joins !== null) {
              delete joins[jid];
            }
          };
        };
      }
      function kill(error3, cb) {
        return function() {
          if (status === COMPLETED) {
            cb(util.right(void 0))();
            return function() {
            };
          }
          var canceler = onComplete({
            rethrow: false,
            handler: function() {
              return cb(util.right(void 0));
            }
          })();
          switch (status) {
            case SUSPENDED:
              interrupt = util.left(error3);
              status = COMPLETED;
              step2 = interrupt;
              run4(runTick);
              break;
            case PENDING:
              if (interrupt === null) {
                interrupt = util.left(error3);
              }
              if (bracketCount === 0) {
                if (status === PENDING) {
                  attempts = new Aff2(CONS, new Aff2(FINALIZER, step2(error3)), attempts, interrupt);
                }
                status = RETURN;
                step2 = null;
                fail = null;
                run4(++runTick);
              }
              break;
            default:
              if (interrupt === null) {
                interrupt = util.left(error3);
              }
              if (bracketCount === 0) {
                status = RETURN;
                step2 = null;
                fail = null;
              }
          }
          return canceler;
        };
      }
      function join2(cb) {
        return function() {
          var canceler = onComplete({
            rethrow: false,
            handler: cb
          })();
          if (status === SUSPENDED) {
            run4(runTick);
          }
          return canceler;
        };
      }
      return {
        kill,
        join: join2,
        onComplete,
        isSuspended: function() {
          return status === SUSPENDED;
        },
        run: function() {
          if (status === SUSPENDED) {
            if (!Scheduler.isDraining()) {
              Scheduler.enqueue(function() {
                run4(runTick);
              });
            } else {
              run4(runTick);
            }
          }
        }
      };
    }
    function runPar(util, supervisor, par, cb) {
      var fiberId = 0;
      var fibers = {};
      var killId = 0;
      var kills = {};
      var early = new Error("[ParAff] Early exit");
      var interrupt = null;
      var root = EMPTY;
      function kill(error3, par2, cb2) {
        var step2 = par2;
        var head3 = null;
        var tail2 = null;
        var count = 0;
        var kills2 = {};
        var tmp, kid;
        loop: while (true) {
          tmp = null;
          switch (step2.tag) {
            case FORKED:
              if (step2._3 === EMPTY) {
                tmp = fibers[step2._1];
                kills2[count++] = tmp.kill(error3, function(result) {
                  return function() {
                    count--;
                    if (count === 0) {
                      cb2(result)();
                    }
                  };
                });
              }
              if (head3 === null) {
                break loop;
              }
              step2 = head3._2;
              if (tail2 === null) {
                head3 = null;
              } else {
                head3 = tail2._1;
                tail2 = tail2._2;
              }
              break;
            case MAP:
              step2 = step2._2;
              break;
            case APPLY:
            case ALT:
              if (head3) {
                tail2 = new Aff2(CONS, head3, tail2);
              }
              head3 = step2;
              step2 = step2._1;
              break;
          }
        }
        if (count === 0) {
          cb2(util.right(void 0))();
        } else {
          kid = 0;
          tmp = count;
          for (; kid < tmp; kid++) {
            kills2[kid] = kills2[kid]();
          }
        }
        return kills2;
      }
      function join2(result, head3, tail2) {
        var fail, step2, lhs, rhs, tmp, kid;
        if (util.isLeft(result)) {
          fail = result;
          step2 = null;
        } else {
          step2 = result;
          fail = null;
        }
        loop: while (true) {
          lhs = null;
          rhs = null;
          tmp = null;
          kid = null;
          if (interrupt !== null) {
            return;
          }
          if (head3 === null) {
            cb(fail || step2)();
            return;
          }
          if (head3._3 !== EMPTY) {
            return;
          }
          switch (head3.tag) {
            case MAP:
              if (fail === null) {
                head3._3 = util.right(head3._1(util.fromRight(step2)));
                step2 = head3._3;
              } else {
                head3._3 = fail;
              }
              break;
            case APPLY:
              lhs = head3._1._3;
              rhs = head3._2._3;
              if (fail) {
                head3._3 = fail;
                tmp = true;
                kid = killId++;
                kills[kid] = kill(early, fail === lhs ? head3._2 : head3._1, function() {
                  return function() {
                    delete kills[kid];
                    if (tmp) {
                      tmp = false;
                    } else if (tail2 === null) {
                      join2(fail, null, null);
                    } else {
                      join2(fail, tail2._1, tail2._2);
                    }
                  };
                });
                if (tmp) {
                  tmp = false;
                  return;
                }
              } else if (lhs === EMPTY || rhs === EMPTY) {
                return;
              } else {
                step2 = util.right(util.fromRight(lhs)(util.fromRight(rhs)));
                head3._3 = step2;
              }
              break;
            case ALT:
              lhs = head3._1._3;
              rhs = head3._2._3;
              if (lhs === EMPTY && util.isLeft(rhs) || rhs === EMPTY && util.isLeft(lhs)) {
                return;
              }
              if (lhs !== EMPTY && util.isLeft(lhs) && rhs !== EMPTY && util.isLeft(rhs)) {
                fail = step2 === lhs ? rhs : lhs;
                step2 = null;
                head3._3 = fail;
              } else {
                head3._3 = step2;
                tmp = true;
                kid = killId++;
                kills[kid] = kill(early, step2 === lhs ? head3._2 : head3._1, function() {
                  return function() {
                    delete kills[kid];
                    if (tmp) {
                      tmp = false;
                    } else if (tail2 === null) {
                      join2(step2, null, null);
                    } else {
                      join2(step2, tail2._1, tail2._2);
                    }
                  };
                });
                if (tmp) {
                  tmp = false;
                  return;
                }
              }
              break;
          }
          if (tail2 === null) {
            head3 = null;
          } else {
            head3 = tail2._1;
            tail2 = tail2._2;
          }
        }
      }
      function resolve(fiber) {
        return function(result) {
          return function() {
            delete fibers[fiber._1];
            fiber._3 = result;
            join2(result, fiber._2._1, fiber._2._2);
          };
        };
      }
      function run4() {
        var status = CONTINUE;
        var step2 = par;
        var head3 = null;
        var tail2 = null;
        var tmp, fid;
        loop: while (true) {
          tmp = null;
          fid = null;
          switch (status) {
            case CONTINUE:
              switch (step2.tag) {
                case MAP:
                  if (head3) {
                    tail2 = new Aff2(CONS, head3, tail2);
                  }
                  head3 = new Aff2(MAP, step2._1, EMPTY, EMPTY);
                  step2 = step2._2;
                  break;
                case APPLY:
                  if (head3) {
                    tail2 = new Aff2(CONS, head3, tail2);
                  }
                  head3 = new Aff2(APPLY, EMPTY, step2._2, EMPTY);
                  step2 = step2._1;
                  break;
                case ALT:
                  if (head3) {
                    tail2 = new Aff2(CONS, head3, tail2);
                  }
                  head3 = new Aff2(ALT, EMPTY, step2._2, EMPTY);
                  step2 = step2._1;
                  break;
                default:
                  fid = fiberId++;
                  status = RETURN;
                  tmp = step2;
                  step2 = new Aff2(FORKED, fid, new Aff2(CONS, head3, tail2), EMPTY);
                  tmp = Fiber(util, supervisor, tmp);
                  tmp.onComplete({
                    rethrow: false,
                    handler: resolve(step2)
                  })();
                  fibers[fid] = tmp;
                  if (supervisor) {
                    supervisor.register(tmp);
                  }
              }
              break;
            case RETURN:
              if (head3 === null) {
                break loop;
              }
              if (head3._1 === EMPTY) {
                head3._1 = step2;
                status = CONTINUE;
                step2 = head3._2;
                head3._2 = EMPTY;
              } else {
                head3._2 = step2;
                step2 = head3;
                if (tail2 === null) {
                  head3 = null;
                } else {
                  head3 = tail2._1;
                  tail2 = tail2._2;
                }
              }
          }
        }
        root = step2;
        for (fid = 0; fid < fiberId; fid++) {
          fibers[fid].run();
        }
      }
      function cancel(error3, cb2) {
        interrupt = util.left(error3);
        var innerKills;
        for (var kid in kills) {
          if (kills.hasOwnProperty(kid)) {
            innerKills = kills[kid];
            for (kid in innerKills) {
              if (innerKills.hasOwnProperty(kid)) {
                innerKills[kid]();
              }
            }
          }
        }
        kills = null;
        var newKills = kill(error3, root, cb2);
        return function(killError) {
          return new Aff2(ASYNC, function(killCb) {
            return function() {
              for (var kid2 in newKills) {
                if (newKills.hasOwnProperty(kid2)) {
                  newKills[kid2]();
                }
              }
              return nonCanceler;
            };
          });
        };
      }
      run4();
      return function(killError) {
        return new Aff2(ASYNC, function(killCb) {
          return function() {
            return cancel(killError, killCb);
          };
        });
      };
    }
    function sequential2(util, supervisor, par) {
      return new Aff2(ASYNC, function(cb) {
        return function() {
          return runPar(util, supervisor, par, cb);
        };
      });
    }
    Aff2.EMPTY = EMPTY;
    Aff2.Pure = AffCtr(PURE);
    Aff2.Throw = AffCtr(THROW);
    Aff2.Catch = AffCtr(CATCH);
    Aff2.Sync = AffCtr(SYNC);
    Aff2.Async = AffCtr(ASYNC);
    Aff2.Bind = AffCtr(BIND);
    Aff2.Bracket = AffCtr(BRACKET);
    Aff2.Fork = AffCtr(FORK);
    Aff2.Seq = AffCtr(SEQ);
    Aff2.ParMap = AffCtr(MAP);
    Aff2.ParApply = AffCtr(APPLY);
    Aff2.ParAlt = AffCtr(ALT);
    Aff2.Fiber = Fiber;
    Aff2.Supervisor = Supervisor;
    Aff2.Scheduler = Scheduler;
    Aff2.nonCanceler = nonCanceler;
    return Aff2;
  }();
  var _pure = Aff.Pure;
  var _throwError = Aff.Throw;
  function _catchError(aff) {
    return function(k) {
      return Aff.Catch(aff, k);
    };
  }
  function _map(f) {
    return function(aff) {
      if (aff.tag === Aff.Pure.tag) {
        return Aff.Pure(f(aff._1));
      } else {
        return Aff.Bind(aff, function(value) {
          return Aff.Pure(f(value));
        });
      }
    };
  }
  function _bind(aff) {
    return function(k) {
      return Aff.Bind(aff, k);
    };
  }
  var _liftEffect = Aff.Sync;
  var makeAff = Aff.Async;
  function _makeFiber(util, aff) {
    return function() {
      return Aff.Fiber(util, null, aff);
    };
  }
  var _sequential = Aff.Seq;

  // output/Effect.Exception/foreign.js
  function error(msg) {
    return new Error(msg);
  }
  function message(e) {
    return e.message;
  }
  function throwException(e) {
    return function() {
      throw e;
    };
  }

  // output/Effect.Exception/index.js
  var $$throw = function($4) {
    return throwException(error($4));
  };

  // output/Control.Monad.Error.Class/index.js
  var catchError = function(dict) {
    return dict.catchError;
  };
  var $$try = function(dictMonadError) {
    var catchError1 = catchError(dictMonadError);
    var Monad0 = dictMonadError.MonadThrow0().Monad0();
    var map3 = map(Monad0.Bind1().Apply0().Functor0());
    var pure4 = pure(Monad0.Applicative0());
    return function(a) {
      return catchError1(map3(Right.create)(a))(function($52) {
        return pure4(Left.create($52));
      });
    };
  };

  // output/Effect.Ref/foreign.js
  var _new = function(val) {
    return function() {
      return { value: val };
    };
  };
  var read = function(ref) {
    return function() {
      return ref.value;
    };
  };
  var write = function(val) {
    return function(ref) {
      return function() {
        ref.value = val;
      };
    };
  };

  // output/Effect.Ref/index.js
  var $$new = _new;

  // output/Effect.Class/index.js
  var liftEffect = function(dict) {
    return dict.liftEffect;
  };

  // output/Partial.Unsafe/foreign.js
  var _unsafePartial = function(f) {
    return f();
  };

  // output/Partial/foreign.js
  var _crashWith = function(msg) {
    throw new Error(msg);
  };

  // output/Partial/index.js
  var crashWith = function() {
    return _crashWith;
  };

  // output/Partial.Unsafe/index.js
  var crashWith2 = /* @__PURE__ */ crashWith();
  var unsafePartial = _unsafePartial;
  var unsafeCrashWith = function(msg) {
    return unsafePartial(function() {
      return crashWith2(msg);
    });
  };

  // output/Effect.Aff/index.js
  var $runtime_lazy2 = function(name2, moduleName, init4) {
    var state2 = 0;
    var val;
    return function(lineNumber) {
      if (state2 === 2) return val;
      if (state2 === 1) throw new ReferenceError(name2 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state2 = 1;
      val = init4();
      state2 = 2;
      return val;
    };
  };
  var $$void2 = /* @__PURE__ */ $$void(functorEffect);
  var functorAff = {
    map: _map
  };
  var ffiUtil = /* @__PURE__ */ function() {
    var unsafeFromRight = function(v) {
      if (v instanceof Right) {
        return v.value0;
      }
      ;
      if (v instanceof Left) {
        return unsafeCrashWith("unsafeFromRight: Left");
      }
      ;
      throw new Error("Failed pattern match at Effect.Aff (line 407, column 21 - line 409, column 54): " + [v.constructor.name]);
    };
    var unsafeFromLeft = function(v) {
      if (v instanceof Left) {
        return v.value0;
      }
      ;
      if (v instanceof Right) {
        return unsafeCrashWith("unsafeFromLeft: Right");
      }
      ;
      throw new Error("Failed pattern match at Effect.Aff (line 402, column 20 - line 404, column 55): " + [v.constructor.name]);
    };
    var isLeft = function(v) {
      if (v instanceof Left) {
        return true;
      }
      ;
      if (v instanceof Right) {
        return false;
      }
      ;
      throw new Error("Failed pattern match at Effect.Aff (line 397, column 12 - line 399, column 21): " + [v.constructor.name]);
    };
    return {
      isLeft,
      fromLeft: unsafeFromLeft,
      fromRight: unsafeFromRight,
      left: Left.create,
      right: Right.create
    };
  }();
  var makeFiber = function(aff) {
    return _makeFiber(ffiUtil, aff);
  };
  var launchAff = function(aff) {
    return function __do() {
      var fiber = makeFiber(aff)();
      fiber.run();
      return fiber;
    };
  };
  var monadAff = {
    Applicative0: function() {
      return applicativeAff;
    },
    Bind1: function() {
      return bindAff;
    }
  };
  var bindAff = {
    bind: _bind,
    Apply0: function() {
      return $lazy_applyAff(0);
    }
  };
  var applicativeAff = {
    pure: _pure,
    Apply0: function() {
      return $lazy_applyAff(0);
    }
  };
  var $lazy_applyAff = /* @__PURE__ */ $runtime_lazy2("applyAff", "Effect.Aff", function() {
    return {
      apply: ap(monadAff),
      Functor0: function() {
        return functorAff;
      }
    };
  });
  var bindFlipped2 = /* @__PURE__ */ bindFlipped(bindAff);
  var monadEffectAff = {
    liftEffect: _liftEffect,
    Monad0: function() {
      return monadAff;
    }
  };
  var liftEffect2 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var monadThrowAff = {
    throwError: _throwError,
    Monad0: function() {
      return monadAff;
    }
  };
  var monadErrorAff = {
    catchError: _catchError,
    MonadThrow0: function() {
      return monadThrowAff;
    }
  };
  var $$try2 = /* @__PURE__ */ $$try(monadErrorAff);
  var runAff = function(k) {
    return function(aff) {
      return launchAff(bindFlipped2(function($77) {
        return liftEffect2(k($77));
      })($$try2(aff)));
    };
  };
  var runAff_ = function(k) {
    return function(aff) {
      return $$void2(runAff(k)(aff));
    };
  };

  // output/Effect.Console/foreign.js
  var log = function(s) {
    return function() {
      console.log(s);
    };
  };

  // output/Flame.Application.Internal.Dom/foreign.js
  function querySelector_(selector) {
    return document.querySelector(selector);
  }
  function createWindowListener_(eventName, updater) {
    window.addEventListener(eventName, function(event) {
      updater(event)();
    });
  }
  function createDocumentListener_(eventName, updater) {
    document.addEventListener(eventName, function(event) {
      updater(event)();
    });
  }
  function createCustomListener_(eventName, updater) {
    document.addEventListener(eventName, function(event) {
      updater(event.detail)();
    });
  }

  // output/Data.Nullable/foreign.js
  function nullable(a, r, f) {
    return a == null ? r : f(a);
  }

  // output/Data.Nullable/index.js
  var toMaybe = function(n) {
    return nullable(n, Nothing.value, Just.create);
  };

  // output/Effect.Uncurried/foreign.js
  var runEffectFn1 = function runEffectFn12(fn) {
    return function(a) {
      return function() {
        return fn(a);
      };
    };
  };
  var runEffectFn2 = function runEffectFn22(fn) {
    return function(a) {
      return function(b) {
        return function() {
          return fn(a, b);
        };
      };
    };
  };
  var runEffectFn4 = function runEffectFn42(fn) {
    return function(a) {
      return function(b) {
        return function(c) {
          return function(d) {
            return function() {
              return fn(a, b, c, d);
            };
          };
        };
      };
    };
  };

  // output/Flame.Application.Internal.Dom/index.js
  var querySelector = function(selector) {
    return function __do() {
      var selected = querySelector_(selector);
      return toMaybe(selected);
    };
  };
  var createWindowListener = /* @__PURE__ */ runEffectFn2(createWindowListener_);
  var createDocumentListener = /* @__PURE__ */ runEffectFn2(createDocumentListener_);
  var createCustomListener = /* @__PURE__ */ runEffectFn2(createCustomListener_);

  // output/Flame.Html.Attribute.Internal/foreign.js
  var propertyData = 3;
  var attributeData = 4;
  function createProperty_(name2) {
    return function(value) {
      return [propertyData, name2, value];
    };
  }
  function createAttribute_(name2) {
    return function(value) {
      return [attributeData, name2, value];
    };
  }

  // output/Data.Array/foreign.js
  var replicateFill = function(count) {
    return function(value) {
      if (count < 1) {
        return [];
      }
      var result = new Array(count);
      return result.fill(value);
    };
  };
  var replicatePolyfill = function(count) {
    return function(value) {
      var result = [];
      var n = 0;
      for (var i = 0; i < count; i++) {
        result[n++] = value;
      }
      return result;
    };
  };
  var replicate = typeof Array.prototype.fill === "function" ? replicateFill : replicatePolyfill;

  // output/Data.Array/index.js
  var singleton3 = function(a) {
    return [a];
  };
  var concatMap = /* @__PURE__ */ flip(/* @__PURE__ */ bind(bindArray));

  // output/Data.String.CodePoints/foreign.js
  var hasArrayFrom = typeof Array.from === "function";
  var hasStringIterator = typeof Symbol !== "undefined" && Symbol != null && typeof Symbol.iterator !== "undefined" && typeof String.prototype[Symbol.iterator] === "function";
  var hasFromCodePoint = typeof String.prototype.fromCodePoint === "function";
  var hasCodePointAt = typeof String.prototype.codePointAt === "function";

  // output/Foreign.Object/foreign.js
  function toArrayWithKey(f) {
    return function(m) {
      var r = [];
      for (var k in m) {
        if (hasOwnProperty.call(m, k)) {
          r.push(f(k)(m[k]));
        }
      }
      return r;
    };
  }
  var keys = Object.keys || toArrayWithKey(function(k) {
    return function() {
      return k;
    };
  });

  // output/Flame.Html.Attribute.Internal/index.js
  var createProperty = function(name1) {
    return function(value1) {
      return createProperty_(name1)(value1);
    };
  };
  var id = /* @__PURE__ */ createProperty("id");
  var createAttribute = function(name1) {
    return function(value1) {
      return createAttribute_(name1)(value1);
    };
  };
  var styleAttr = /* @__PURE__ */ createAttribute("style");

  // output/Flame.Html.Element/foreign.js
  var textNode = 1;
  var elementNode = 2;
  var styleData = 1;
  var classData = 2;
  var propertyData2 = 3;
  var attributeData2 = 4;
  var keyData = 7;
  function createElementNode(tag) {
    return function(nodeData) {
      return function(potentialChildren) {
        let children = potentialChildren, text2 = void 0;
        if (potentialChildren.length === 1 && potentialChildren[0].nodeType == textNode) {
          children = void 0;
          text2 = potentialChildren[0].text;
        }
        return {
          nodeType: elementNode,
          node: void 0,
          tag,
          nodeData: fromNodeData(nodeData),
          children,
          text: text2
        };
      };
    };
  }
  function text(value) {
    return {
      nodeType: textNode,
      node: void 0,
      text: value
    };
  }
  function fromNodeData(allData) {
    let nodeData = {};
    if (allData !== void 0)
      for (let data of allData) {
        let dataOne = data[1];
        switch (data[0]) {
          case styleData:
            if (nodeData.styles === void 0)
              nodeData.styles = {};
            for (let key in dataOne)
              nodeData.styles[key] = dataOne[key];
            break;
          case classData:
            if (nodeData.classes === void 0)
              nodeData.classes = [];
            nodeData.classes = nodeData.classes.concat(dataOne);
            break;
          case propertyData2:
            if (nodeData.properties === void 0)
              nodeData.properties = {};
            nodeData.properties[dataOne] = data[2];
            break;
          case attributeData2:
            if (nodeData.attributes === void 0)
              nodeData.attributes = {};
            nodeData.attributes[dataOne] = data[2];
            break;
          case keyData:
            nodeData.key = dataOne;
            break;
          default:
            if (nodeData.events === void 0)
              nodeData.events = {};
            if (nodeData.events[dataOne] === void 0)
              nodeData.events[dataOne] = [];
            nodeData.events[dataOne].push(data[2]);
        }
      }
    return nodeData;
  }

  // output/Flame.Html.Element/index.js
  var toNode = function(dict) {
    return dict.toNode;
  };
  var stringToNodeData = {
    toNode: function($767) {
      return singleton3(id($767));
    }
  };
  var stringToHtml = {
    toNode: function($768) {
      return singleton3(text($768));
    }
  };
  var nodeDataToNodedata = {
    toNode: singleton3
  };
  var htmlToHtml = {
    toNode: singleton3
  };
  var createElement = function(tag) {
    return function(dictToNode) {
      var toNode1 = toNode(dictToNode);
      return function(dictToNode1) {
        var toNode2 = toNode(dictToNode1);
        return function(nodeData) {
          return function(children) {
            return createElementNode(tag)(toNode1(nodeData))(toNode2(children));
          };
        };
      };
    };
  };
  var main = function(dictToNode) {
    return function(dictToNode1) {
      return createElement("main")(dictToNode)(dictToNode1);
    };
  };
  var span = function(dictToNode) {
    return function(dictToNode1) {
      return createElement("span")(dictToNode)(dictToNode1);
    };
  };
  var button = function(dictToNode) {
    return function(dictToNode1) {
      return createElement("button")(dictToNode)(dictToNode1);
    };
  };
  var arrayToNodeData = function(dictToNode) {
    return {
      toNode: concatMap(toNode(dictToNode))
    };
  };

  // output/Flame.Renderer.String/foreign.js
  var reUnescapedHtml = /[&<>"']/g;
  var reHasUnescapedHtml = RegExp(reUnescapedHtml.source);

  // output/Flame.Internal.Equality/foreign.js
  function compareReference_(a) {
    return function(b) {
      return a === b;
    };
  }

  // output/Flame.Internal.Equality/index.js
  var compareReference = function(a) {
    return function(a2) {
      return compareReference_(a)(a2);
    };
  };
  var modelHasChanged = function(old) {
    return function($$new2) {
      return !compareReference(old)($$new2);
    };
  };

  // output/Flame.Renderer.Internal.Dom/foreign.js
  var namespace = "http://www.w3.org/2000/svg";
  var eventPrefix = "__flame_";
  var eventPostfix = "updater";
  var textNode2 = 1;
  var elementNode2 = 2;
  var svgNode = 3;
  var fragmentNode = 4;
  var lazyNode = 5;
  var managedNode = 6;
  var nonBubblingEvents = ["focus", "blur", "scroll"];
  function start_(eventWrapper, root, updater, html) {
    return new F(eventWrapper, root, updater, html, false);
  }
  function startFrom_(eventWrapper, root, updater, html) {
    return new F(eventWrapper, root, updater, html, true);
  }
  function resume_(f, html) {
    f.resume(html);
  }
  function F(eventWrapper, root, updater, html, isDry) {
    this.eventWrapper = eventWrapper;
    this.applicationEvents = /* @__PURE__ */ new Map();
    this.root = root;
    this.updater = updater;
    this.cachedHtml = html.node === void 0 ? html : shallowCopy(html);
    if (isDry)
      this.hydrate(this.root, this.cachedHtml);
    else
      this.createAllNodes(this.root, this.cachedHtml);
  }
  F.prototype.hydrate = function(parent, html, referenceNode) {
    switch (html.nodeType) {
      case lazyNode:
        html.node = parent;
        html.rendered = html.render(html.arg);
        html.render = void 0;
        this.hydrate(parent, html.rendered);
        break;
      case textNode2:
        html.node = parent;
        break;
      case managedNode:
        this.createAllNodes(parent, html, referenceNode);
        break;
      default:
        if (html.nodeType === fragmentNode)
          html.node = document.createDocumentFragment();
        else {
          html.node = parent;
          if (html.nodeData.events !== void 0)
            this.createAllEvents(parent, html);
        }
        let htmlChildrenLength;
        if (html.text === void 0 && html.children !== void 0 && (htmlChildrenLength = html.children.length) > 0) {
          let childNodes = parent.childNodes;
          for (let i = 0, cni = 0; i < htmlChildrenLength; ++i, ++cni) {
            let c = html.children[i] = html.children[i].node === void 0 ? html.children[i] : shallowCopy(html.children[i]);
            if (childNodes[cni] === void 0)
              this.createAllNodes(parent, c);
            else {
              if (c.nodeType === fragmentNode) {
                let fragmentChildrenLength = c.children.length;
                c.node = document.createDocumentFragment();
                for (let j = 0; j < fragmentChildrenLength; ++j) {
                  let cf = c.children[j] = c.children[j].node === void 0 ? c.children[j] : shallowCopy(c.children[j]);
                  this.hydrate(childNodes[cni++], cf);
                }
                cni--;
              } else if (c.nodeType === managedNode)
                this.hydrate(parent, c, childNodes[cni]);
              else
                this.hydrate(childNodes[cni], c);
            }
          }
        }
    }
  };
  function shallowCopy(origin) {
    switch (origin.nodeType) {
      case textNode2:
        return {
          nodeType: textNode2,
          node: void 0,
          text: origin.text
        };
      case fragmentNode:
        return {
          nodeType: fragmentNode,
          node: void 0,
          children: origin.children
        };
      case lazyNode:
        return {
          nodeType: lazyNode,
          node: void 0,
          nodeData: origin.nodeData,
          render: origin.render,
          arg: origin.arg,
          rendered: void 0,
          messageMapper: origin.messageMapper
        };
      case managedNode:
        return {
          nodeType: managedNode,
          node: void 0,
          nodeData: origin.nodeData,
          createNode: origin.createNode,
          updateNode: origin.updateNode,
          arg: origin.arg,
          messageMapper: origin.messageMapper
        };
      default:
        return {
          nodeType: origin.nodeType,
          node: void 0,
          tag: origin.tag,
          nodeData: origin.nodeData,
          children: origin.children,
          text: origin.text,
          messageMapper: origin.messageMapper
        };
    }
  }
  F.prototype.createAllNodes = function(parent, html, referenceNode) {
    let node = this.createNode(html);
    if (html.text !== void 0)
      node.textContent = html.text;
    else {
      if (html.children !== void 0)
        this.createChildrenNodes(node, html.children);
      else if (html.rendered !== void 0) {
        if (html.messageMapper !== void 0)
          lazyMessageMap(html.messageMapper, html.rendered);
        if (html.rendered.text !== void 0) {
          node.textContent = html.rendered.text;
        } else if (html.rendered.children !== void 0)
          this.createChildrenNodes(node, html.rendered.children);
      }
    }
    parent.insertBefore(node, referenceNode);
  };
  F.prototype.checkCreateAllNodes = function(parent, html, referenceNode) {
    if (html.node !== void 0)
      html = shallowCopy(html);
    this.createAllNodes(parent, html, referenceNode);
    return html;
  };
  F.prototype.createChildrenNodes = function(parent, children) {
    let childrenLength = children.length;
    for (let i = 0; i < childrenLength; ++i) {
      let c = children[i] = children[i].node === void 0 ? children[i] : shallowCopy(children[i]), node = this.createNode(c);
      if (c.text !== void 0)
        node.textContent = c.text;
      else {
        if (c.children !== void 0)
          this.createChildrenNodes(node, c.children);
        else if (c.rendered !== void 0) {
          if (c.messageMapper !== void 0)
            lazyMessageMap(c.messageMapper, c.rendered);
          if (c.rendered.children !== void 0)
            this.createChildrenNodes(node, c.rendered.children);
        }
      }
      parent.appendChild(node);
    }
  };
  F.prototype.createNode = function(html) {
    switch (html.nodeType) {
      case lazyNode:
        html.rendered = html.render(html.arg);
        html.render = void 0;
        return html.node = this.createNode(html.rendered);
      case textNode2:
        return html.node = document.createTextNode(html.text);
      case elementNode2:
        return html.node = this.createElement(html);
      case svgNode:
        return html.node = this.createSvg(html);
      case fragmentNode:
        return html.node = document.createDocumentFragment();
      case managedNode:
        return html.node = this.createManagedNode(html);
    }
  };
  F.prototype.createElement = function(html) {
    let element = document.createElement(html.tag);
    this.createNodeData(element, html, false);
    return element;
  };
  F.prototype.createSvg = function(html) {
    let svg = document.createElementNS(namespace, html.tag);
    this.createNodeData(svg, html, true);
    return svg;
  };
  F.prototype.createManagedNode = function(html) {
    let node = html.createNode(html.arg)();
    html.createNode = void 0;
    this.createNodeData(node, html, node instanceof SVGElement || node.nodeName.toLowerCase() === "svg");
    return node;
  };
  F.prototype.createNodeData = function(node, html, isSvg) {
    if (html.nodeData.styles !== void 0)
      createStyles(node, html.nodeData.styles);
    if (html.nodeData.classes !== void 0 && html.nodeData.classes.length > 0)
      createClasses(node, html.nodeData.classes, isSvg);
    if (html.nodeData.attributes !== void 0)
      createAttributes(node, html.nodeData.attributes);
    if (html.nodeData.properties !== void 0)
      for (let key in html.nodeData.properties)
        node[key] = html.nodeData.properties[key];
    if (html.nodeData.events !== void 0)
      this.createAllEvents(node, html);
  };
  function createStyles(node, styles) {
    for (let key in styles)
      node.style.setProperty(key, styles[key]);
  }
  function createClasses(node, classes, isSvg) {
    let joined = classes.join(" ");
    if (isSvg)
      node.setAttribute("class", joined);
    else
      node.className = joined;
  }
  function createAttributes(node, attributes) {
    for (let key in attributes)
      node.setAttribute(key, attributes[key]);
  }
  F.prototype.createAllEvents = function(node, html) {
    for (let key in html.nodeData.events)
      this.createEvent(node, key, html);
  };
  F.prototype.createEvent = function(node, name2, html) {
    let handlers = html.nodeData.events[name2], eventKey = eventPrefix + name2;
    if (nonBubblingEvents.includes(name2)) {
      let runNonBubblingEvent = this.runNonBubblingEvent(handlers, html.messageMapper);
      node[eventKey] = runNonBubblingEvent;
      node.addEventListener(name2, runNonBubblingEvent, false);
    } else {
      node[eventKey] = handlers;
      if (html.messageMapper !== void 0)
        node[eventKey + eventPostfix] = html.messageMapper;
      let synthethic = this.applicationEvents.get(name2);
      if (synthethic === void 0) {
        let runEvent = this.runEvent.bind(this);
        this.root.addEventListener(name2, runEvent, false);
        this.applicationEvents.set(name2, {
          count: 1,
          handler: runEvent
        });
      } else
        synthethic.count++;
    }
  };
  F.prototype.runNonBubblingEvent = function(handlers, messageMapper2) {
    return function(event) {
      this.runHandlers(handlers, messageMapper2, event);
    }.bind(this);
  };
  F.prototype.runEvent = function(event) {
    let node = event.target, eventKey = eventPrefix + event.type;
    while (node !== this.root) {
      let handlers = node[eventKey];
      if (handlers !== void 0) {
        this.runHandlers(handlers, node[eventKey + eventPostfix], event);
        return;
      }
      node = node.parentNode;
    }
  };
  F.prototype.runHandlers = function(handlers, messageMapper2, event) {
    let handlersLength = handlers.length;
    for (let i = 0; i < handlersLength; ++i) {
      let h = handlers[i], maybeMessage = typeof h === "function" ? h(event)() : this.eventWrapper(h);
      this.updater(messageMapper2 === void 0 ? maybeMessage : messageMapper2(maybeMessage))();
    }
    event.stopPropagation();
  };
  F.prototype.resume = function(updatedHtml) {
    this.cachedHtml = this.updateAllNodes(this.root, this.cachedHtml, updatedHtml);
    ;
  };
  F.prototype.updateAllNodes = function(parent, currentHtml2, updatedHtml) {
    if (updatedHtml.node !== void 0)
      updatedHtml = shallowCopy(updatedHtml);
    if (currentHtml2.tag !== updatedHtml.tag || currentHtml2.nodeType !== updatedHtml.nodeType) {
      this.createAllNodes(parent, updatedHtml, currentHtml2.node);
      parent.removeChild(currentHtml2.node);
    } else {
      updatedHtml.node = currentHtml2.node;
      switch (updatedHtml.nodeType) {
        case lazyNode:
          if (updatedHtml.arg !== currentHtml2.arg) {
            updatedHtml.rendered = updatedHtml.render(updatedHtml.arg);
            if (updatedHtml.messageMapper !== void 0)
              lazyMessageMap(updatedHtml.messageMapper, updatedHtml.rendered);
            this.updateAllNodes(parent, currentHtml2.rendered, updatedHtml.rendered);
          } else
            updatedHtml.rendered = currentHtml2.rendered;
          updatedHtml.render = void 0;
          break;
        case managedNode:
          let node = updatedHtml.updateNode(currentHtml2.node)(currentHtml2.arg)(updatedHtml.arg)(), isSvg = node instanceof SVGElement || node.nodeName.toLowerCase() === "svg";
          if (node !== currentHtml2.node || node.nodeType !== currentHtml2.node.nodeType || node.nodeName !== currentHtml2.node.nodeName) {
            this.createNodeData(node, updatedHtml, isSvg);
            parent.insertBefore(node, currentHtml2.node);
            parent.removeChild(currentHtml2.node);
          } else
            this.updateNodeData(node, currentHtml2.nodeData, updatedHtml, isSvg);
          updatedHtml.node = node;
          break;
        //text nodes can have only their textContent changed
        case textNode2:
          if (updatedHtml.text !== currentHtml2.text)
            updatedHtml.node.textContent = updatedHtml.text;
          break;
        //parent instead of currentHtml.node, as fragments nodes only count for their children
        case fragmentNode:
          this.updateChildrenNodes(parent, currentHtml2, updatedHtml);
          break;
        //the usual case, element/svg to be patched
        default:
          this.updateNodeData(currentHtml2.node, currentHtml2.nodeData, updatedHtml, updatedHtml.nodeType == svgNode);
          if ((updatedHtml.text !== void 0 || updatedHtml.children === void 0 && currentHtml2.text != void 0) && !hasInnerHtml(updatedHtml.nodeData) && updatedHtml.text != currentHtml2.node.textContent)
            currentHtml2.node.textContent = updatedHtml.text;
          else
            this.updateChildrenNodes(currentHtml2.node, currentHtml2, updatedHtml);
      }
    }
    return updatedHtml;
  };
  function clearNode(node) {
    node.textContent = "";
  }
  F.prototype.updateChildrenNodes = function(parent, currentHtml2, updatedHtml) {
    let currentChildren = currentHtml2.children, updatedChildren = updatedHtml.children;
    if (currentChildren === void 0 || currentChildren.length === 0) {
      let updatedChildrenLength;
      if (updatedChildren !== void 0 && (updatedChildrenLength = updatedChildren.length) > 0) {
        if (currentHtml2.text !== void 0 || hasInnerHtml(currentHtml2.nodeData))
          clearNode(parent);
        for (let i = 0; i < updatedChildrenLength; ++i)
          updatedChildren[i] = this.checkCreateAllNodes(parent, updatedChildren[i]);
      }
    } else if (updatedChildren === void 0 || updatedChildren.length === 0) {
      if (currentChildren !== void 0 && (currentChildren.length > 0 || currentHtml2.text !== void 0) && !hasInnerHtml(updatedHtml.nodeData))
        clearNode(parent);
    } else if (currentChildren[0].nodeData !== void 0 && currentChildren[0].nodeData.key !== void 0 && updatedChildren[0].nodeData !== void 0 && updatedChildren[0].nodeData.key !== void 0)
      this.updateKeyedChildrenNodes(parent, currentChildren, updatedChildren);
    else
      this.updateNonKeyedChildrenNodes(parent, currentChildren, updatedChildren);
  };
  function hasInnerHtml(parentNodeData) {
    return parentNodeData !== void 0 && parentNodeData.properties !== void 0 && parentNodeData.properties.innerHTML !== void 0;
  }
  F.prototype.updateKeyedChildrenNodes = function(parent, currentChildren, updatedChildren) {
    let currentStart = 0, updatedStart = 0, currentEnd = currentChildren.length - 1, updatedEnd = updatedChildren.length - 1;
    let afterNode, currentStartNode = currentChildren[currentStart].node, updatedStartNode = currentStartNode, currentEndNode = currentChildren[currentEnd].node;
    let loop = true;
    fixes: while (loop) {
      loop = false;
      let currentHtml2 = currentChildren[currentStart], updatedHtml = updatedChildren[updatedStart];
      while (currentHtml2.nodeData.key === updatedHtml.nodeData.key) {
        updatedHtml = this.updateAllNodes(parent, currentHtml2, updatedHtml);
        updatedStartNode = currentStartNode = currentHtml2.node.nextSibling;
        currentStart++;
        updatedStart++;
        if (currentEnd < currentStart || updatedEnd < updatedStart)
          break fixes;
        currentHtml2 = currentChildren[currentStart];
        updatedHtml = updatedChildren[updatedStart];
      }
      currentHtml2 = currentChildren[currentEnd];
      updatedHtml = updatedChildren[updatedEnd];
      while (currentHtml2.nodeData.key === updatedHtml.nodeData.key) {
        updatedHtml = this.updateAllNodes(parent, currentHtml2, updatedHtml);
        afterNode = currentEndNode;
        currentEndNode = currentEndNode.previousSibling;
        currentEnd--;
        updatedEnd--;
        if (currentEnd < currentStart || updatedEnd < updatedStart)
          break fixes;
        currentHtml2 = currentChildren[currentEnd];
        updatedHtml = updatedChildren[updatedEnd];
      }
      currentHtml2 = currentChildren[currentEnd];
      updatedHtml = updatedChildren[updatedStart];
      while (currentHtml2.nodeData.key === updatedHtml.nodeData.key) {
        loop = true;
        updatedHtml = this.updateAllNodes(parent, currentHtml2, updatedHtml);
        currentEndNode = currentHtml2.node.previousSibling;
        parent.insertBefore(currentHtml2.node, updatedStartNode);
        updatedStart++;
        currentEnd--;
        if (currentEnd < currentStart || updatedEnd < updatedStart)
          break fixes;
        currentHtml2 = currentChildren[currentEnd];
        updatedHtml = updatedChildren[updatedStart];
      }
      currentHtml2 = currentChildren[currentStart];
      updatedHtml = updatedChildren[updatedEnd];
      while (currentHtml2.nodeData.key === updatedHtml.nodeData.key) {
        loop = true;
        updatedHtml = this.updateAllNodes(parent, currentHtml2, updatedHtml);
        parent.insertBefore(currentHtml2.node, afterNode);
        afterNode = currentHtml2.node;
        currentStart++;
        updatedEnd--;
        if (currentEnd < currentStart || updatedEnd < updatedStart)
          break fixes;
        currentHtml2 = currentChildren[currentStart];
        updatedHtml = updatedChildren[updatedEnd];
      }
    }
    if (updatedEnd < updatedStart)
      while (currentStart <= currentEnd) {
        parent.removeChild(currentChildren[currentEnd].node);
        currentEnd--;
      }
    else if (currentEnd < currentStart)
      while (updatedStart <= updatedEnd) {
        updatedChildren[updatedStart] = this.checkCreateAllNodes(parent, updatedChildren[updatedStart], afterNode);
        updatedStart++;
      }
    else {
      let P = new Int32Array(updatedEnd + 1 - updatedStart);
      let I = /* @__PURE__ */ new Map();
      for (let i = updatedStart; i <= updatedEnd; i++) {
        P[i] = -1;
        I.set(updatedChildren[i].nodeData.key, i);
      }
      let reusingNodes = updatedStart + updatedChildren.length - 1 - updatedEnd, toRemove = [];
      for (let i = currentStart; i <= currentEnd; i++)
        if (I.has(currentChildren[i].nodeData.key)) {
          P[I.get(currentChildren[i].nodeData.key)] = i;
          reusingNodes++;
        } else
          toRemove.push(i);
      if (reusingNodes === 0) {
        parent.textContent = "";
        for (let i = updatedStart; i <= updatedEnd; i++)
          updatedChildren[i] = this.checkCreateAllNodes(parent, updatedChildren[i]);
      } else {
        let toRemoveLength = toRemove.length;
        for (let i = 0; i < toRemoveLength; i++)
          parent.removeChild(currentChildren[toRemove[i]].node);
        let longestSeq = longestSubsequence(P, updatedStart), seqIndex = longestSeq.length - 1;
        for (let i = updatedEnd; i >= updatedStart; i--) {
          if (longestSeq[seqIndex] === i) {
            currentHtml = currentChildren[P[longestSeq[seqIndex]]];
            updatedChildren[i] = this.updateAllNodes(parent, currentHtml, updatedChildren[i]);
            afterNode = currentHtml.node;
            seqIndex--;
          } else {
            if (P[i] === -1) {
              updatedChildren[i] = this.checkCreateAllNodes(parent, updatedChildren[i], afterNode);
              afterNode = updatedChildren[i].node;
            } else {
              currentHtml = currentChildren[P[i]];
              updatedChildren[i] = this.updateAllNodes(parent, currentHtml, updatedChildren[i]);
              parent.insertBefore(currentHtml.node, afterNode);
              afterNode = currentHtml.node;
            }
          }
        }
      }
    }
  };
  function longestSubsequence(ns, updatedStart) {
    let seq = [], is = [], l = -1, i, len, pre = new Int32Array(ns.length);
    for (i = updatedStart, len = ns.length; i < len; i++) {
      let n = ns[i];
      if (n < 0)
        continue;
      let j = findGreatestIndex(seq, n);
      if (j !== -1)
        pre[i] = is[j];
      if (j === l) {
        l++;
        seq[l] = n;
        is[l] = i;
      } else if (n < seq[j + 1]) {
        seq[j + 1] = n;
        is[j + 1] = i;
      }
    }
    for (i = is[l]; l >= 0; i = pre[i], l--)
      seq[l] = i;
    return seq;
  }
  function findGreatestIndex(seq, n) {
    let lo = -1, hi = seq.length;
    if (hi > 0 && seq[hi - 1] <= n)
      return hi - 1;
    while (hi - lo > 1) {
      let mid = Math.floor((lo + hi) / 2);
      if (seq[mid] > n)
        hi = mid;
      else
        lo = mid;
    }
    return lo;
  }
  F.prototype.updateNonKeyedChildrenNodes = function(parent, currentChildren, updatedChildren) {
    let currentChildrenLength = currentChildren.length, updatedChildrenLength = updatedChildren.length, commonLength = Math.min(currentChildrenLength, updatedChildrenLength);
    for (let i = 0; i < commonLength; ++i)
      updatedChildren[i] = this.updateAllNodes(parent, currentChildren[i], updatedChildren[i]);
    if (currentChildrenLength < updatedChildrenLength)
      for (let i = commonLength; i < updatedChildrenLength; ++i)
        updatedChildren[i] = this.checkCreateAllNodes(parent, updatedChildren[i]);
    else if (currentChildrenLength > updatedChildrenLength)
      for (let i = commonLength; i < currentChildrenLength; ++i)
        parent.removeChild(currentChildren[i].node);
  };
  F.prototype.updateNodeData = function(node, currentNodeData, updatedHtml, isSvg) {
    updateStyles(node, currentNodeData.styles, updatedHtml.nodeData.styles);
    updateAttributes(node, currentNodeData.attributes, updatedHtml.nodeData.attributes);
    updateClasses(node, currentNodeData.classes, updatedHtml.nodeData.classes, isSvg);
    updateProperties(node, currentNodeData.properties, updatedHtml.nodeData.properties);
    this.updateEvents(node, currentNodeData.events, updatedHtml);
  };
  function updateStyles(node, currentStyles, updatedStyles) {
    if (currentStyles === void 0) {
      if (updatedStyles !== void 0)
        createStyles(node, updatedStyles);
    } else if (updatedStyles === void 0) {
      if (currentStyles !== void 0)
        node.removeAttribute("style");
    } else {
      let matchCount = 0;
      for (let key in currentStyles) {
        let current = currentStyles[key], updated = updatedStyles[key], hasUpdated = updatedStyles[key] !== void 0;
        if (hasUpdated)
          matchCount++;
        if (current !== updated)
          if (hasUpdated)
            node.style.setProperty(key, updated);
          else
            node.style.removeProperty(key);
      }
      let newKeys = Object.keys(updatedStyles), newKeysLength = newKeys.length;
      for (let i = 0; matchCount < newKeysLength && i < newKeysLength; ++i) {
        let key = newKeys[i];
        if (currentStyles[key] === void 0) {
          let updated = updatedStyles[key];
          ++matchCount;
          node.style.setProperty(key, updated);
        }
      }
    }
  }
  function updateClasses(node, currentClasses, updatedClasses, isSvg) {
    let classUpdated = updatedClasses !== void 0 && updatedClasses.length > 0;
    if (currentClasses !== void 0 && currentClasses.length > 0 && !classUpdated)
      createClasses(node, [], isSvg);
    else if (classUpdated)
      createClasses(node, updatedClasses, isSvg);
  }
  function updateAttributes(node, currentAttributes, updatedAttributes) {
    if (currentAttributes === void 0) {
      if (updatedAttributes !== void 0)
        createAttributes(node, updatedAttributes);
    } else if (updatedAttributes === void 0) {
      if (currentAttributes !== void 0)
        for (let key in currentAttributes)
          node.removeAttribute(key);
    } else {
      let matchCount = 0;
      for (let key in currentAttributes) {
        let current = currentAttributes[key], updated = updatedAttributes[key], hasUpdated = updated !== void 0;
        if (hasUpdated)
          matchCount++;
        if (current !== updated)
          if (hasUpdated)
            node.setAttribute(key, updated);
          else
            node.removeAttribute(key);
      }
      let newKeys = Object.keys(updatedAttributes), newKeysLength = newKeys.length;
      for (let i = 0; matchCount < newKeysLength && i < newKeysLength; ++i) {
        let key = newKeys[i];
        if (currentAttributes[key] === void 0) {
          let updated = updatedAttributes[key];
          ++matchCount;
          node.setAttribute(key, updated);
        }
      }
    }
  }
  function updateProperties(node, currentProperties, updatedProperties) {
    let addAll = currentProperties === void 0, removeAll = updatedProperties === void 0;
    if (addAll) {
      if (!removeAll)
        for (let key in updatedProperties)
          node[key] = updatedProperties[key];
    } else if (removeAll) {
      if (!addAll)
        for (let key in currentProperties)
          node.removeAttribute(key);
    } else {
      let matchCount = 0;
      for (let key in currentProperties) {
        let current = currentProperties[key], updated = updatedProperties[key], hasUpdated = updated !== void 0;
        if (hasUpdated)
          matchCount++;
        if (current !== updated)
          if (hasUpdated)
            node[key] = updated;
          else
            node.removeAttribute(key);
      }
      let newKeys = Object.keys(updatedProperties), newKeysLength = newKeys.length;
      for (let i = 0; matchCount < newKeysLength && i < newKeysLength; ++i) {
        let key = newKeys[i];
        if (currentProperties[key] === void 0) {
          let updated = updatedProperties[key];
          ++matchCount;
          node[key] = updated;
        }
      }
    }
  }
  F.prototype.updateEvents = function(node, currentEvents, updatedHtml) {
    let updatedEvents = updatedHtml.nodeData.events;
    if (currentEvents === void 0) {
      if (updatedEvents !== void 0)
        this.createAllEvents(node, updatedHtml);
    } else if (updatedEvents === void 0) {
      if (currentEvents !== void 0)
        for (let key in currentEvents)
          this.removeEvent(node, key);
    } else {
      let matchCount = 0;
      for (let key in currentEvents) {
        let current = currentEvents[key], updated = updatedEvents[key], hasUpdated = false;
        if (updated === void 0)
          this.removeEvent(node, key);
        else {
          let currentLength = current.length, updatedLength = updated.length;
          if (currentLength != updatedLength)
            hasUpdated = true;
          else {
            for (let i = 0; i < currentLength; ++i)
              if (current[i] != updated[i]) {
                hasUpdated = true;
                break;
              }
          }
        }
        if (hasUpdated) {
          matchCount++;
          this.removeEvent(node, key);
          this.createEvent(node, key, updatedHtml);
        }
      }
      let newKeys = Object.keys(updatedEvents), newKeysLength = newKeys.length;
      for (let i = 0; matchCount < newKeysLength && i < newKeysLength; ++i) {
        let key = newKeys[i];
        if (currentEvents[key] === void 0) {
          ++matchCount;
          this.createEvent(node, key, updatedHtml);
        }
      }
    }
  };
  F.prototype.removeEvent = function(node, name2) {
    let eventKey = eventPrefix + name2;
    if (nonBubblingEvents.includes(name2)) {
      let runNonBubblingEvent = node[eventKey];
      node.removeEventListener(name2, runNonBubblingEvent, false);
    } else {
      let count = --this.applicationEvents.get(name2).count;
      if (count === 0) {
        this.root.removeEventListener(name2, this.applicationEvents.get(name2).handler, false);
        this.applicationEvents.delete(name2);
      }
    }
    node[eventKey + eventPostfix] = void 0;
    node[eventKey] = void 0;
  };
  function lazyMessageMap(mapper, html) {
    html.messageMapper = mapper;
    if (html.children !== void 0 && html.children.length > 0)
      for (let i = 0; i < html.children.length; ++i)
        lazyMessageMap(mapper, html.children[i]);
  }

  // output/Flame.Renderer.Internal.Dom/index.js
  var pure2 = /* @__PURE__ */ pure(applicativeEffect);
  var resume = /* @__PURE__ */ runEffectFn2(resume_);
  var maybeUpdater = function(updater) {
    return function(v) {
      if (v instanceof Just) {
        return updater(v.value0);
      }
      ;
      return pure2(unit);
    };
  };
  var start = function(parent) {
    return function(updater) {
      return runEffectFn4(start_)(Just.create)(parent)(maybeUpdater(updater));
    };
  };
  var startFrom = function(parent) {
    return function(updater) {
      return runEffectFn4(startFrom_)(Just.create)(parent)(maybeUpdater(updater));
    };
  };

  // output/Flame.Subscription.Internal.Listener/foreign.js
  var applicationIds = /* @__PURE__ */ new Set();
  function checkApplicationId_(id3) {
    if (applicationIds.has(id3))
      throw `Error mounting application: id ${id3} already registered!`;
    applicationIds.add(id3);
  }

  // output/Flame.Types/index.js
  var Window = /* @__PURE__ */ function() {
    function Window2() {
    }
    ;
    Window2.value = new Window2();
    return Window2;
  }();
  var Document = /* @__PURE__ */ function() {
    function Document2() {
    }
    ;
    Document2.value = new Document2();
    return Document2;
  }();
  var Custom = /* @__PURE__ */ function() {
    function Custom2() {
    }
    ;
    Custom2.value = new Custom2();
    return Custom2;
  }();

  // output/Foreign/foreign.js
  var isArray = Array.isArray || function(value) {
    return Object.prototype.toString.call(value) === "[object Array]";
  };

  // output/Foreign/index.js
  var unsafeFromForeign = unsafeCoerce2;

  // output/Flame.Subscription.Internal.Listener/index.js
  var createSubscription = function(updater) {
    return function(v) {
      if (v.value0 instanceof Window) {
        return createWindowListener(v.value1.value0)(function($13) {
          return updater(v.value1.value1.value0($13));
        });
      }
      ;
      if (v.value0 instanceof Document) {
        return createDocumentListener(v.value1.value0)(function($14) {
          return updater(v.value1.value1.value0($14));
        });
      }
      ;
      if (v.value0 instanceof Custom) {
        return createCustomListener(v.value1.value0)(function($15) {
          return updater(v.value1.value1.value0($15));
        });
      }
      ;
      throw new Error("Failed pattern match at Flame.Subscription.Internal.Listener (line 31, column 83 - line 34, column 76): " + [v.value0.constructor.name]);
    };
  };
  var checkApplicationId = /* @__PURE__ */ runEffectFn1(checkApplicationId_);
  var createMessageListener = function(appId) {
    return function(updater) {
      return function __do() {
        checkApplicationId(appId)();
        return createCustomListener(appId)(function($16) {
          return updater(unsafeFromForeign($16));
        })();
      };
    };
  };

  // output/Flame.Application.EffectList/index.js
  var when2 = /* @__PURE__ */ when(applicativeEffect);
  var for_2 = /* @__PURE__ */ for_(applicativeEffect)(foldableArray);
  var pure3 = /* @__PURE__ */ pure(applicativeEffect);
  var traverse_2 = /* @__PURE__ */ traverse_(applicativeEffect)(foldableArray);
  var map2 = /* @__PURE__ */ map(functorMaybe);
  var showId = function(dictShow) {
    var show3 = show(dictShow);
    return function(v) {
      return show3(v);
    };
  };
  var run3 = function(parent) {
    return function(isResumed) {
      return function(appId) {
        return function(v) {
          return function __do() {
            var modelState = $$new(v.init.value0)();
            var renderingState = $$new(21)();
            var render2 = function(model) {
              return function __do2() {
                var rendering2 = read(renderingState)();
                resume(rendering2)(v.view(model))();
                return write(model)(modelState)();
              };
            };
            var runUpdate = function(message2) {
              return function __do2() {
                var currentModel = read(modelState)();
                var v1 = v.update(currentModel)(message2);
                when2(modelHasChanged(currentModel)(v1.value0))(render2(v1.value0))();
                return runMessages(v1.value1)();
              };
            };
            var runMessages = function(affs) {
              return for_2(affs)(runAff_(function(v1) {
                if (v1 instanceof Left) {
                  return log(message(v1.value0));
                }
                ;
                if (v1 instanceof Right && v1.value0 instanceof Just) {
                  return runUpdate(v1.value0.value0);
                }
                ;
                return pure3(unit);
              }));
            };
            var rendering = function() {
              if (isResumed) {
                return startFrom(parent)(runUpdate)(v.view(v.init.value0))();
              }
              ;
              return start(parent)(runUpdate)(v.view(v.init.value0))();
            }();
            write(rendering)(renderingState)();
            runMessages(v.init.value1)();
            (function() {
              if (appId instanceof Nothing) {
                return unit;
              }
              ;
              if (appId instanceof Just) {
                return createMessageListener(appId.value0)(runUpdate)();
              }
              ;
              throw new Error("Failed pattern match at Flame.Application.EffectList (line 142, column 7 - line 144, column 63): " + [appId.constructor.name]);
            })();
            return traverse_2(createSubscription(runUpdate))(v.subscribe)();
          };
        };
      };
    };
  };
  var noAppId = /* @__PURE__ */ function() {
    return Nothing.value;
  }();
  var mountWith = function(dictShow) {
    var showId1 = showId(dictShow);
    return function(v) {
      return function(appId) {
        return function(application) {
          return function __do() {
            var maybeElement = querySelector(v)();
            if (maybeElement instanceof Just) {
              return run3(maybeElement.value0)(false)(map2(showId1)(appId))(application)();
            }
            ;
            if (maybeElement instanceof Nothing) {
              return $$throw("Error mounting application")();
            }
            ;
            throw new Error("Failed pattern match at Flame.Application.EffectList (line 102, column 7 - line 104, column 63): " + [maybeElement.constructor.name]);
          };
        };
      };
    };
  };
  var mountWith1 = /* @__PURE__ */ mountWith(showUnit);
  var mount_ = function(selector) {
    return mountWith1(selector)(noAppId);
  };

  // output/Flame.Application.NoEffects/index.js
  var mount_2 = function(selector) {
    return function(application) {
      return mount_(selector)({
        view: application.view,
        subscribe: application.subscribe,
        init: new Tuple(application.init, []),
        update: function(model) {
          return function(message2) {
            return new Tuple(application.update(model)(message2), []);
          };
        }
      });
    };
  };

  // output/Flame.Html.Event/foreign.js
  var messageEventData = 5;
  function createEvent_(name2) {
    return function(message2) {
      return [messageEventData, name2, message2];
    };
  }

  // output/Flame.Html.Event/index.js
  var createEvent = function(name2) {
    return function(message2) {
      return createEvent_(name2)(message2);
    };
  };
  var onClick = /* @__PURE__ */ createEvent("click");

  // output/Main/index.js
  var arrayToNodeData2 = /* @__PURE__ */ arrayToNodeData(htmlToHtml);
  var main1 = /* @__PURE__ */ main(stringToNodeData)(arrayToNodeData2);
  var arrayToNodeData1 = /* @__PURE__ */ arrayToNodeData(nodeDataToNodedata);
  var button2 = /* @__PURE__ */ button(arrayToNodeData1)(stringToHtml);
  var span4 = /* @__PURE__ */ span(arrayToNodeData1)(arrayToNodeData2);
  var show2 = /* @__PURE__ */ show(showInt);
  var Increment = /* @__PURE__ */ function() {
    function Increment2() {
    }
    ;
    Increment2.value = new Increment2();
    return Increment2;
  }();
  var Decrement = /* @__PURE__ */ function() {
    function Decrement2() {
    }
    ;
    Decrement2.value = new Decrement2();
    return Decrement2;
  }();
  var update = function(model) {
    return function(v) {
      if (v instanceof Increment) {
        return model + 1 | 0;
      }
      ;
      if (v instanceof Decrement) {
        return model - 1 | 0;
      }
      ;
      throw new Error("Failed pattern match at Main (line 24, column 16 - line 26, column 24): " + [v.constructor.name]);
    };
  };
  var init3 = 0;
  var bgColor = function(model) {
    var $15 = model < 0;
    if ($15) {
      return "red;";
    }
    ;
    return "lime;";
  };
  var view = function(model) {
    return main1("main")([button2([onClick(Decrement.value)])("-"), span4([styleAttr("background-color: " + (bgColor(model) + "margin: auto 1em;"))])([text(show2(model))]), button2([onClick(Increment.value)])("+")]);
  };
  var main2 = /* @__PURE__ */ mount_2("body")({
    init: init3,
    subscribe: [],
    update,
    view
  });

  // <stdin>
  main2();
})();
