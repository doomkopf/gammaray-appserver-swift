const FUNC_VISIBILITY_PUBLIC = 0
const FUNC_VISIBILITY_PRIVATE = 1

const echo = {
    vis: FUNC_VISIBILITY_PUBLIC,
    func(lib, params, ctx) {
        ctx.sendResponse(params)
    },
}

const createPerson = {
    vis: FUNC_VISIBILITY_PUBLIC,
    func: (entity, id, lib, params, ctx) => {
        entity = {
            name: params.entityName
        }
        return entity
    },
}

const loadPerson = {
    vis: FUNC_VISIBILITY_PUBLIC,
    func: (entity, id, lib, params, ctx) => {
        ctx.sendResponse(entity)
    },
}

const testUserLogin = {
    vis: FUNC_VISIBILITY_PUBLIC,
    func(lib, params, ctx) {
        lib.user.login("myUserId", "loginFinished", { myCustomContext: "test" })
    },
}

const loginFinished = {
    vis: FUNC_VISIBILITY_PRIVATE,
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
                loadPerson,
            },
        },
    },
}
