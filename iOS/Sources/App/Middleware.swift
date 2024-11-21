import Vapor
import JWT

struct JWTMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        do {
            _ = try request.jwt.verify(as: UserPayload.self)
            return next.respond(to: request)
        } catch {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Invalid or missing token."))
        }
    }
}
