(import [functools [wraps]])

(import jwt)
(import [flask [jsonify request]])

(import [hyscores.mongodb [collection]])


(setv secret "very secret"
      users (collection "users"))


(defn check_token [func]
  #@((wraps func)
      (defn wrap [#*args #**kwargs]
        (setv token None)
        (if (in "x-access-tokens" (. request headers))
            (setv token (get (. request headers) "x-access-tokens")))
        (if (not token)
            (return (jsonify {"message" "token not found"})))

        (setv data (jwt.decode token secret :algorithms ["HS256"])
              user (users.find_one {"login" (get data "login")
                                    "app" (get data "app")}))
        (return (func user #*args #**kwargs))))
  (return wrap))
