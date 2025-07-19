enum AdminCommandType: Int, Decodable {
    case DEPLOY_NODEJS_APP = 0
}

struct DeployNodeJsAppCommandRequest: Codable {
    let appId: String
    let code: String
}

struct DeployNodeJsAppCommandResponse: Codable {
}
