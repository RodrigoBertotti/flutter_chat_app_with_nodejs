const bcrypt = require("bcrypt")

/** Generates a hash by using a random generated salt */
export async function hashEncryption (unecryptedSecret:string) : Promise<string> {
    const salt = await randomSalt();
    return await bcrypt.hash(unecryptedSecret, salt);
}

/** Verifies if the unecryptedSecret and the ecryptedSecret matches */
export async function verify(unecryptedSecret:string, ecryptedSecret:string) : Promise<boolean> {
    return bcrypt.compare(unecryptedSecret, ecryptedSecret);
}

async function randomSalt() : Promise<string> {
    return await bcrypt.genSalt(10);
}