import {UserModel} from "../../data/models/user-model";
import {UsersService, UsersServiceParams} from "../../domain/services/users-service";
import {Controller} from "../../domain/controllers-and-services";
import {UserEntity} from "../../domain/entity/user-entity";
import {AsklessServer, AuthenticateUserContext} from "askless";
import {ReadRouteInstance} from "askless/route/ReadRoute";


export class UserController implements Controller {
    private userListRouteInstance: ReadRouteInstance<UserEntity[], AuthenticateUserContext<number>>;
    private readonly usersService:UsersService;

    constructor(initUsersService:(params:UsersServiceParams) => UsersService) {
        this.usersService = initUsersService({
            notifyNewUserWasCreated: (userId:number) => {
                this.userListRouteInstance.notifyChanges({
                    where: context => {
                        return context.userId != userId;
                    }
                })
            }
        });
    }

    initializeRoutes (server: AsklessServer<number>) : void {
        server.addRoute.forAllUsers.create({
            route: 'user',
            handleCreate: async (context) => {
                const user = await UserModel.fromBody(context.body);
                const res = await this.usersService.saveUser(user);
                if(res.isRight()){
                    context.successCallback(res.value);
                    return;
                }
                context.errorCallback(res.error.errorParams);
            },
            toOutput: (entity) => UserModel.fromEntity(entity).output(),
        });

        this.userListRouteInstance = server.addRoute.forAuthenticatedUsers.read<UserEntity[]>({
            route: 'user-list',
            handleRead: async (context) => {
                console.log("user-list: read started");
                const mainUserId:number = context.userId;
                if (mainUserId == null) {
                    context.errorCallback({
                        description: "Only logged users can perform this operation",
                        code: "FORBIDDEN",
                    })
                    return;
                }
                const users = await this.usersService.getAllUsers({ exceptUserId: mainUserId });
// TODO: NO GIF, MOSTRAR DESDE A CRIAÇÃO DE USUÁRIO EM REALTIME, COMO O OUTRO USUÁRIO JÁ APARECE INSTANTANEAMENTE!

                context.successCallback(users.sort((a,b) => {
                    const aName = `${a.firstName} ${a.lastName}`;
                    const bName = `${b.firstName} ${b.lastName}`;
                    return aName.localeCompare(bName);
                }));
            },
            toOutput: (entities) => {
                return UserModel.fromEntityList(entities).map((user) => user.output())
            },
        });
    }

}
