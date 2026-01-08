# Gammaray application server engine (in Swift-on-Server)

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

The first goal is to learn Swift better and the other is rewriting the appserver with an even better design. In the previous version I used a top-down approach first starting with the webserver part to have an executable application as early as possible. This wasn't helpful for the design since I didn't know the requirements of the SDK/API for an app yet. This time I'm starting from the bottom(core) first specifying exactly how functions of an application are executed. The application was not executable for a long time, but there are unit- and integration tests that prove the functionality of independant components even better. The last thing that was implemented this time was the webserver on top of everything, which eventually made the application executable and usable.

## Micro-Services
First of all: Gammaray is not Micro-Services.

But one important aspect of Micro-Services is: If a bug or crash occurs, it only affects one logical service. While Gammaray eliminates most problems already without being a Micro-Service architecture, this is the only problem that still remains.

I'm gonna use the word "application" here very often and what I mean by that is a backend application covering business data. A client/frontend application does synchronous requests to APIs of course.

Building a Micro-Service architecture with Gammaray could be done by writing multiple applications while one logical application represents one logical service - no matter if you separate them logically or physically.
What’s needed here is some sort of communication between those applications, with the important point to only publish domain events that can be consumed by other services to enforce asynchronous communication (and also DDD) - NO requests to APIs (which can still be done with the http client, but that’s not the official way to build the architecture).

Just a side note from my experience: A very important point that many companies with multiple backend applications are doing wrong: As soon as you start doing requests to other services to get needed data, you're acting against the whole idea of Micro-Services. People argue with "... but we're not doing Micro-Services" - then my question is always "Why do you have multiple applications then?". The point is: If you need data from another application you either have both applications as one or you communicate asynchronously through domain events - anything else makes no sense.
