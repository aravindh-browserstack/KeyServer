# KeyServer
KeyServer Implementation in Ruby


## Requirements

Write a server which can generate random api keys, assign them for usage and release them after sometime. Following endpoints should be available on the server to interact with it.

E1. There should be one endpoint to generate keys.

E2. There should be an endpoint to get an available key. On hitting this endpoint server should serve a random key which is not already being used. This key should be blocked and should not be served again by E2, till it is in this state. If no eligible key is available then it should serve 404.

E3. There should be an endpoint to unblock a key. Unblocked keys can be served via E2 again.

E4. There should be an endpoint to delete a key. Deleted keys should be purged.

E5. All keys are to be kept alive by clients calling this endpoint every 5 minutes. If a particular key has not received a keep alive in last five minutes then it should be deleted and never used again. 

Apart from these endpoints, following rules should be enforced:
R1. All blocked keys should get released automatically within 60 secs if E3 is not called.
No endpoint call should result in an iteration of whole set of keys i.e. no endpoint request should be O(n). They should either be O(lg n) or O(1).


## API Description

1) POST /keys 
   Generates keys

2) GET /keys
   Returns one available key for use by the client
   
3) HEAD /keys/:id
   Information ( timestamps of assignment ) for inspection about the key

4) DELETE /keys/:id
   Deletes the specified key denoted by :id ( which was previously granted )

5) PUT /keys/:id
   Recycles the used key ( unblocks )for further use

6) PUT /keepalive/:id
   Keeps alive the specified key identified by :id from garbage-collection/recycling by the server
   
## Running tests
```bash
rspec test_keyserver_spec.rb
```
## Running the program
```bash
bundle install
rackup -p <port>
```
