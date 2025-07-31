const echo = {
    vis: 1,
    func(lib, params, ctx) {
        ctx.sendResponse(params)
    },
}

const createPerson = {
    vis: 1,
    func: (entity, id, lib, params, ctx) => {
        entity = {
            name: params.entityName
        }
        return entity
    },
}

const testUserLogin = {
    vis: 1,
    func(lib, params, ctx) {
        lib.user.login("myUserId", "loginFinished", { myCustomContext: "test" })
    },
}

const loginFinished = {
    vis: 1,
    func(lib, params, ctx) {
        ctx.sendResponse(params)
        lib.user.send("myUserId", { msg: "pushed message" })
    },
}

const app = {
    func: {
        echo,
        testUserLogin,
        loginFinished,
    },
    entity: {
        person: {
            currentVersion: 1,
            func: {
                createPerson,
            },
        },
    },
}
