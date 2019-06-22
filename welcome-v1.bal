import ballerina/http;
import ballerina/log;
import ballerinax/docker;

@docker:Expose {}
listener http:Listener welcomeEP = new(9090);

@docker:Config {
    name: "welcome",
    tag: "v1.0"
}
@http:ServiceConfig {
    basePath: "/welcome"
}
service welcome on welcomeEP {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/{location}"
    }
    resource function sayWelcome(http:Caller caller, http:Request req, string location) {
        var result = caller->respond("Welcome to WSO API Day - "+ untaint location+ "!");
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }
}

