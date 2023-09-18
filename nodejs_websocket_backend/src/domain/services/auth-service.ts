import {Either, Left, Right} from "../../utils/either";
import {InvalidEmailFailure} from "../entity/failures/invalid-email-failure";
import {InvalidPasswordFailure} from "../entity/failures/invalid-password-failure";
import {TokensEntity} from "../entity/tokens-entity";
import * as encryption from "../../utils/encryption-utils";
import {generateAccessToken, generateRefreshToken} from "../../utils/jwt-utils";
import {Failure} from "../entity/failures/failure";
import {InvalidRefreshTokenFailure} from "../entity/failures/invalid-refresh-token-failure";
import {UsersService} from "./users-service";
import {AsklessServer} from "askless";


export class AuthService {

    constructor(
       private readonly usersService: UsersService,
       private readonly server: AsklessServer<number>,
    ) {
        if (usersService == null) {
            throw Error('AuthService: usersService == null');
        }
    }

    async login(email: string, password: string) : Promise<Either<InvalidEmailFailure | InvalidPasswordFailure, TokensEntity>> {
        try {
            const user = await this.usersService.getUserByEmail(email);
            if(!user){
                return Left.create(new InvalidEmailFailure());
            }
            if(!(await encryption.verify(password, user.passwordHash))){
                return Left.create(new InvalidPasswordFailure());
            }
            const refreshToken = generateRefreshToken();
            user.refreshTokenHash = await encryption.hashEncryption(refreshToken);
            const saveUserRes = await this.usersService.saveUser(user);
            if(saveUserRes.isLeft()) {
                console.error(saveUserRes.error);
                return Left.create(new Failure(`An error ocurred when updating the refresh token of the user`));
            }
            const accessToken = generateAccessToken(user.userId);
            return Right.create(new TokensEntity(user.userId, accessToken.accessToken, accessToken.accessTokenExpiration, refreshToken))
        } catch (e) {
            console.error("authenticate error:");
            console.error(e.toString());
            return Left.create(new Failure());
        }
    }

    async logout (userId: number) : Promise<void> {
        this.server.clearAuthentication(userId);
        await this.usersService.updateUser(userId, {
            refreshTokenHash: null,
        })
    }

    async generateNewAccessToken (userId: number, refreshToken: string) : Promise<Either<InvalidRefreshTokenFailure, TokensEntity>> {
        try {
            const user = await this.usersService.getUserById(userId);
            if (!user) {
                console.error(`User "${userId}" not found`);
                return Left.create(new Failure(`User "${userId}" not found`));
            }
            if (!(await encryption.verify(refreshToken,user.refreshTokenHash))) {
                console.error(`An invalid refresh token was given`);
                return Left.create(new InvalidRefreshTokenFailure(`An invalid refresh token was given`));
            }
            const accessToken = generateAccessToken(userId);
            return Right.create(new TokensEntity(userId, accessToken.accessToken, accessToken.accessTokenExpiration, refreshToken));
        } catch (e) {
            console.error("generateNewAccessToken error:");
            console.error(e.toString());
            return Left.create(new Failure());
        }
    }
}
