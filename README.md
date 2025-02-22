#Zig Cli

Setup Database First:
create it, connect to it, then setup tables( for me I use psql )
Then use the CLI to do inserts, selects, deletes, and updates

Store information in ~/.config/ziglc/config.json

The next step:
Capture Output so it is returnable in a function
    This will have to be done in ./src/pg_proto_response.zig so that instead of printing values are returned
To do this I will have to setup an array in Handle Query function and have data returned and ignore non values such as errors or notices
Then make the stuff return first in sendquery in query messages then in public sendquery function
Items below might not be necessary
Create Zig file
Struct Generation
Function Generation
