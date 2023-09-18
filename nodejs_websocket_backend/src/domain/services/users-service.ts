import {UserEntity} from "../entity/user-entity";
import {AppDataSource} from "../../data/data-source/db-datasouce";
import {DuplicateEmailFailure} from "../entity/failures/duplicate-email-failure";
import {Either, Left, Right} from "../../utils/either";
import {Equal, In, Not} from "typeorm";
import {Failure} from "../entity/failures/failure";

export type UsersServiceParams = {
    notifyNewUserWasCreated: (userId:number) => void
};
export class UsersService {
    constructor(private readonly params: UsersServiceParams) {}

    private readonly _usersTypeormRepo = AppDataSource.getRepository(UserEntity);

    async updateUser(userId:number, updateData: Partial<Record<keyof UserEntity, any>>) : Promise<void> {
       await AppDataSource.manager.update(UserEntity, userId, updateData);
    }

    async saveUser(user:UserEntity) : Promise<Either<DuplicateEmailFailure | Failure, UserEntity>> {
        try {
            user = Object.assign(new UserEntity(), user);
            user = await this._usersTypeormRepo.save(user);
            this.params.notifyNewUserWasCreated(user.userId);
            return Right.create(user);
        } catch (e) {
            if(e.code == "ER_DUP_ENTRY") {
                return Left.create(new DuplicateEmailFailure(user.email));
            } else if (e.code?.length) {
                throw `TODO: ${e.code}`;
            }
            console.error("saveUser error:");
            console.error(e.toString());
            return Left.create(new Failure());
        }
    }

    async getAllUsers(params?:{exceptUserId?:number}) : Promise<UserEntity[]> {
        if (params?.exceptUserId == null) {
            return this._usersTypeormRepo.find();
        }
        return this._usersTypeormRepo.find({
            where: {
                userId: Not(params.exceptUserId)
            }
        })
    }

    getUserByEmail(email: string) : Promise<UserEntity> {
        return this._usersTypeormRepo.findOneBy({email: email});
    }
    getUserById(userId:number) : Promise<UserEntity> {
        return this._usersTypeormRepo.findOneBy({userId: userId});
    }
}
