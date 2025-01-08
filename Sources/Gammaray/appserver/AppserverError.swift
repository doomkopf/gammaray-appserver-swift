enum AppserverError: Error {
    case General(String)
    case NodeJsApp(String)
}
