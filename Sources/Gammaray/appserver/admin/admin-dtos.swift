enum AdminCommandType: Int {
    case DEPLOY_NODEJS_APP = 0
}

struct DeployNodeJsAppCommandPayload: Codable {
    let appId: String
    let code: String
}
