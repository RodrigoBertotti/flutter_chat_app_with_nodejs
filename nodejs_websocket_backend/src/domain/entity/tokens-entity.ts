


export class TokensEntity {

    constructor(
        public readonly userId:number,
        public readonly accessToken:string,
        public readonly accessTokenExpiration:Date,
        public readonly refreshToken:string,
    ) {}
}