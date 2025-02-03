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

const app = {
    func: {
        echo,
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
