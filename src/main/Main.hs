{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PolyKinds         #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE TypeOperators     #-}

import           Data.Aeson
import           Data.Proxy
import           Data.Text
import           GHC.Generics
import           Network.Wai
import           Network.Wai.Handler.Warp
import           Network.Wai.Middleware.RequestLogger

import           Servant

-- * Example

-- | User definition
data User =
     User {
            name :: Text
          , age  :: Int
          } deriving (Generic)

instance FromJSON User
instance ToJSON User

-- API specification
type UsersApi =
       -- POST /users with an User as JSON in the request body,
       --             returns an User as JSON
       "users" :> ReqBody '[JSON] User :> Post '[JSON] User

usersApi :: Proxy UsersApi
usersApi = Proxy

-- Server-side handlers.
--
-- There's one handler per endpoint, which, just like in the type
-- that represents the API, are glued together using :<|>.
--
-- Each handler runs in the 'EitherT ServantErr IO' monad.
server :: Server UsersApi
server = usersH

  where usersH user = return user { age = age user * 2 }

-- Turn the server into a WAI app. 'serve' is provided by servant,
-- more precisely by the Servant.Server module.
app :: Application
app = logStdout $ serve usersApi server

-- Run the server.
--
-- 'run' comes from Network.Wai.Handler.Warp
runServer :: Port -> IO ()
runServer port = run port app

-- Put this all to work!
main :: IO ()
main = runServer 8001
