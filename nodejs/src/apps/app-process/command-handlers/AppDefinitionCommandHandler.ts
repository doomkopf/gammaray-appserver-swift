import { RequestContext } from "../../../lib/communication/RequestContext";
import { FuncVisibility } from "../api/core";
import { AppCommandHandler } from "../AppCommandHandler";
import { NodeJsEntityFunc, NodeJsFuncVisibility, NodeJsGammarayApp, NodeJsGetAppDefinitionRequest } from "./dtos";

export class AppDefinitionCommandHandler extends AppCommandHandler {
    handleAppCommand(payload: NodeJsGetAppDefinitionRequest, ctx?: RequestContext): void {
        const app = this.apps.getApp(payload.appId)
        if (!app) {
            return
        }

        const appDef: NodeJsGammarayApp = {
            sfunc: {},
            entity: {},
        }

        for (const func in app.func) {
            const v = app.func[func]
            appDef.sfunc[func] = { vis: mapFuncVisibility(v.vis) }
        }

        for (const type in app.entity) {
            const entityType = app.entity[type]
            const efunc: { [func: string]: NodeJsEntityFunc } = {}
            for (const func in entityType.func) {
                const v = entityType.func[func]
                efunc[func] = { vis: mapFuncVisibility(v.vis) }
            }
            appDef.entity[type] = { efunc }
        }

        ctx?.respond(JSON.stringify(appDef))
    }
}

function mapFuncVisibility(vis: FuncVisibility): NodeJsFuncVisibility {
    if (vis === FuncVisibility.pub) {
        return NodeJsFuncVisibility.PUB
    }
    return NodeJsFuncVisibility.PRI
}
