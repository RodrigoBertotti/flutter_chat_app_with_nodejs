import {UserController} from "../controllers/user-controller/user-controller";
import {MessageController} from "../controllers/message-controller/message-controller";
import {AuthController} from "../controllers/auth-controller/auth-controller";
import {MessagesService} from "./services/messages-service";
import {AuthService} from "./services/auth-service";
import {UsersService} from "./services/users-service";
import {AsklessServer} from "askless";

export interface Controller {
    initializeRoutes (server: AsklessServer) : void;
}

let _usersService:UsersService;
let _messagesService:MessagesService;
let _authService:AuthService;
let _authController:AuthController;
let _controllers:Array<Controller>;

export const controllers = () => _controllers;

export function initializeControllers (server:AsklessServer) {
    _controllers = [
        new UserController(params => _usersService = new UsersService(params)),
        new MessageController(params => _messagesService = new MessagesService(params)),
        _authController = new AuthController(_authService = new AuthService(_usersService, server)),
    ];
    return _controllers;
}

export function authController() { return _authController; }
export function authService() { return _authService; }
export function messagesService() { return _messagesService; }
export function usersService() { return _usersService; }
