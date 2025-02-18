function callLibFunctions(ctx, lib, prefix) {
    ctx.sendResponse({ response: prefix + "someResponse" })
    lib.entityFunc.invoke(prefix + "theType", "theFunc", "theEntityId", { testJson: 123 }, ctx)
    lib.entityFunc.invoke(prefix + "theType2", "theFunc2", "theEntityId2", { testJson: 124 }, ctx)
    lib.user.send(prefix + "theUserId", { testJson: 125 })
    lib.user.send(prefix + "theUserId2", { testJson: 126 })
    lib.user.login(prefix + "theUserId", "finishedFunc1", { testJson: 127 })
    lib.user.login(prefix + "theUserId2", "finishedFunc2")
    lib.user.logout(prefix + "theUserId")
    lib.user.logout(prefix + "theUserId2")
    lib.entityQueries.query(prefix + "theType", "queryFinishedFunc", { attributes: [] })
    lib.entityQueries.query(prefix + "theType2", "queryFinishedFunc2", { attributes: [] }, { testJson: 128 })
    lib.httpClient.request(prefix + "theUrl", "GET", "theBody", { headers: [{ key: "headerKey", value: "headerValue" }] }, "httpResultFunc", { testJson: 129 })
    lib.httpClient.request(prefix + "theUrl2", "POST", null, { headers: [] }, "httpResultFunc2")
}

const entityFuncTest = {
    vis: 1,
    func: (entity, id, lib, payload, ctx) => {
        entity.name = entity.name + payload.moreTest

        callLibFunctions(ctx, lib, "entity")

        return entity
    },
}

const funcTest = {
    vis: 1,
    func(lib, params, ctx) {
        callLibFunctions(ctx, lib, "stateless")
    },
}

const app = {
    func: {
        test: funcTest,
    },
    entity: {
        person: {
            currentVersion: 1,
            func: {
                test: entityFuncTest,
            },
        },
    },
}
