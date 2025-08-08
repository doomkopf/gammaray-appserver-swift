func runGammaray() async throws {
    print("Starting gammaray...")
    let components = try await createComponents()
    print("... gammaray started - starting webserver...")
    do {
        try await runWebserver(components: components)
    } catch {
        print(error)
    }

    print("Shutting down gammaray...")
    await components.shutdown()
    print("... gammaray shut down")
}
