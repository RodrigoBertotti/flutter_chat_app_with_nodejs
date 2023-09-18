import "reflect-metadata"
import { DataSource } from "typeorm"
import {dbDatasourceOptions} from "../../environment/db";

export const AppDataSource = new DataSource(dbDatasourceOptions);
