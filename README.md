pgrest-schemaless
===============

a schemaless database with firebase API on PgREST.

This is not working at all right now, please check back later.

# Concept

![](https://dl.dropboxusercontent.com/u/125794/pgrest-schemaless-concept.png)

1. A Reference is a JSON Pointer point to a specified path to data JSON.
2. References can use `set` to set the value of json it pointed to, generate a JSON Patch to local data JSON.
3. Client should apply the JSON Patch to its local data json.
4. Client should trigger all references' event listener immediately if they're referencing the changed data.
5. Client then send the patch to server.
6. Server take the patch, apply to the data json inside Postgres DB.
7. Server then propagates the patch to other clients.

