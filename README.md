# Gammaray application server engine (attempt in Swift)

Soon maybe a scalable application server engine.

## Motivation

Basically the same as the js version, but written in Swift, still supporting js apps that are executed in a sidecar node.js process and later native Swift apps.

I like node.js but sometimes this whole node/js/npm thing feels a bit unstable, wild and still it is an interpreted script language. After researching other modern languages, I found out that Swift is a very nice, stable and clear language with a fantastic concurrency model and a clear build process. No need for linter rules, typescript rules, webpack - it is all handled by SourceKit with clear rules. And it compiles to native binaries.

The first goal is to learn Swift better and the other is rewriting the appserver with an even better design. In the previous version I used a top-down approach first starting with the webserver part to have an executable application as early as possible. This wasn't helpful for the design since I didn't know the requirements of the SDK/API for an app yet. This time I'm starting from the bottom(core) first specifying exactly how functions of an application are executed. The application is not executable yet, but there are unit- and integration tests that prove the functionality of independant components even better. The last thing that will be implemented this time is the webserver on top of everything, which will eventually make the application executable and usable. But first things first...
