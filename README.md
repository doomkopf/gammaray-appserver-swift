# Gammaray application server engine (attempt in Swift)

A (later distributed) “cache” or stateful application server where the state transition happens directly and atomically at the addressed state(=entity). The state is not read and written back by an external application like in traditional caches or databases. This eliminates all the classical performance issues and problems with locking, transactions and waiting on I/O.

Or in other words: It eliminates the problem that in databases you can't program complex state transitions.

It basically is an inversion of the classical processing flow:

### Classical
State is read from the database into the memory of an application. Potential locking is done before. The state is mutated in the memory of the application and written back to the database. This means: The state is brought to the processing - which is a pretty heavyweight process depending on how big the state is.

### Gammaray
State is already in the memory of the application. The state is addressed with a specific function and the function is asynchronously executed directly where the state is located - potentially even on another physical machine. This means: The processing is brought to the state - which is a more lightweight process since the addressing/message just contains some parameters.

## Motivation

Basically the same as the js version, but written in Swift, still supporting js apps that are executed in a sidecar node.js process and later native Swift apps.

I like node.js but sometimes this whole node/js/npm thing feels a bit unstable, wild and still it is an interpreted script language. After researching other modern languages, I found out that Swift is a very nice, stable and clear language with a fantastic concurrency model and a clear build process. No need for linter rules, typescript rules, webpack - it is all handled by SourceKit with clear rules. And it compiles to native binaries.

The first goal is to learn Swift better and the other is rewriting the appserver with an even better design. In the previous version I used a top-down approach first starting with the webserver part to have an executable application as early as possible. This wasn't helpful for the design since I didn't know the requirements of the SDK/API for an app yet. This time I'm starting from the bottom(core) first specifying exactly how functions of an application are executed. The application is not executable yet, but there are unit- and integration tests that prove the functionality of independant components even better. The last thing that will be implemented this time is the webserver on top of everything, which will eventually make the application executable and usable. But first things first...
