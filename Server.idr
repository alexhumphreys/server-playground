module Server

import System
import System.Info
import System.File
import Network.Socket
import Network.Socket.Data
import Network.Socket.Raw

responseText : String
responseText = """
    HTTP/1.1 200 OK
    Content-Type: application/json

    {}
    """

testSocket : String
testSocket = "./idris2_test.socket"

runServer : IO ()
runServer = do
  Right sock <- socket AF_INET Stream 0
        | Left fail => putStrLn $ "Failed to open socket: " ++ show fail
  res <- bind sock (Just (Hostname "localhost")) 8000
  if res /= 0
    then putStrLn $ "Failed to bind socket with error: " ++ show res
    else do
      port <- getSockPort sock
      listenLoop forever sock
  where
    sendResponse : Socket -> IO ()
    sendResponse s = do
      putStrLn ("s: " ++ (show s.descriptor))
      Right  (str, _) <- recv s 1024
        | Left err => putStrLn ("Failed to accept on socket with error: " ++ show err)
      putStrLn ("Received req")
      Right n <- send s responseText
        | Left err => putStrLn ("Server failed to send data with error: " ++ show err)
      close s
      putStrLn ("response sent. closed.")
      pure ()

    serve : Socket -> IO ()
    serve sock = do
      Right (s, _) <- accept sock
        | Left err => putStrLn ("Failed to accept on socket with error: " ++ show err)
      putStrLn ("s: " ++ (show s.descriptor))
      putStrLn "forking"
      _ <- fork $ sendResponse s
      pure ()
    listenLoop : Fuel -> Socket -> IO ()
    listenLoop Dry sock = putStrLn $ "out of fuel"
    listenLoop (More fuel) sock = do
      res <- listen sock
      if res /= 0
         then putStrLn $ "Failed to listen on socket with error: " ++ show res
         else do (serve sock)
                 putStrLn "looping"
                 listenLoop fuel sock

main : IO ()
main = do
  runServer
