const entityFuncTest = {
    vis: 1,
    func: (entity, id, lib, payload, ctx) => {
        entity.name = entity.name + payload.moreTest

        ctx.sendResponse({ response: "someResponse" })
        lib.entityFunc.invoke("theType", "theFunc", "theEntityId", { testJson: 123 }, ctx)
        lib.entityFunc.invoke("theType2", "theFunc2", "theEntityId2", { testJson: 124 }, ctx)

        return entity
    },
}

const funcTest = {
    vis: 1,
    func(lib, params, ctx) {
        ctx.sendResponse({ response: `statelessFuncResponse${params.text}` })
        lib.entityFunc.invoke("theTypeStatelessFunc", "theFuncStatelessFunc", "theEntityIdStatelessFunc", { testJson: 123 }, ctx)
        lib.entityFunc.invoke("theType2StatelessFunc", "theFunc2StatelessFunc", "theEntityId2StatelessFunc", { testJson: 124 }, ctx)
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
