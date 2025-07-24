enum AdminCommandType: Int, Decodable {
    case DEPLOY_NODEJS_APP = 0
}

struct DeployNodeJsAppCommandRequest: Codable {
    let appId: String
    let pw: String
    let script: String
}

struct DeployNodeJsAppCommandResponse: Codable {
    let errorMsg: String?
}
