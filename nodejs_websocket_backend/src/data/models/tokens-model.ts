import {TokensEntity} from "../../domain/entity/tokens-entity";

export interface TokensOutputToClient {
    [TokensModel.kAccessToken]: string;
    [TokensModel.kRefreshToken]: string;
    [TokensModel.kUserId]: number;
    [TokensModel.kAccessTokenExpirationMsSinceEpoch]: number;
}

export class TokensModel extends TokensEntity {
    static readonly kAccessToken = "accessToken";
    static readonly kRefreshToken = "refreshToken";
    static readonly kUserId = "userId";
    static readonly kAccessTokenExpirationMsSinceEpoch = "accessTokenExpirationMsSinceEpoch";

    output() : TokensOutputToClient {
        return {
            [TokensModel.kAccessToken]: this.accessToken,
            [TokensModel.kRefreshToken]: this.refreshToken,
            [TokensModel.kUserId]: this.userId,
            [TokensModel.kAccessTokenExpirationMsSinceEpoch]: this.accessTokenExpiration.getTime(),
        }
    }

    static fromEntity (entity:TokensEntity) : TokensModel {
        return Object.assign(new TokensModel(null,null,null,null), entity);
    }

}