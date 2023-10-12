import * as fs from "fs";
import * as path from "path";
import * as jwt from "jsonwebtoken";

const privateKey = fs.readFileSync(path.join(__dirname, '../', 'environment', 'jwt-private.key'), {encoding: "utf-8"});
const expiresInSeconds:number = 30 * 60;

export function generateAccessToken (userId:number) : { accessToken:string, accessTokenExpiration:Date } {
    const accessTokenExpirationMsSinceEpoch:number = Date.now() + (expiresInSeconds * 1000);
    return {
        'accessToken': jwt.sign({ userId: userId }, privateKey, {
            expiresIn: expiresInSeconds
        }),
        'accessTokenExpiration': new Date(accessTokenExpirationMsSinceEpoch)
    }
}
export function verifyJwtAccessToken(jwtAccessToken:string) : { userId?:number, valid:boolean, claims?:string[], locals? } {
    try {
        const res = jwt.verify(jwtAccessToken, privateKey);
        return {
            valid: true,
            userId: (res as any).userId,
            // optionally set the user claims and locals here
            claims: [],
            locals: {},
        };
    } catch (e) {
        return { valid: false };
    }
}
export function generateRefreshToken()  {
    //https://stackoverflow.com/a/8084248/4508758
    return (Math.random() + 1).toString(36).substring(2);
}
