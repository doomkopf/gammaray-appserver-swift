protocol StatelessFunctions: Sendable {
    func invoke(_ params: FunctionParams) async
}
