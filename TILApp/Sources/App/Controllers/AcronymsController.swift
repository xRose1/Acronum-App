

import Vapor

struct AcronymsController: RouteCollection {
  func boot(router: Router) throws {
    let acronymsRoute = router.grouped("api", "acronyms")
    acronymsRoute.get(use: getAllHandler)
    acronymsRoute.post(Acronym.self, use: createHandler)
    acronymsRoute.get(Acronym.parameter, use: getHandler)
    acronymsRoute.delete(Acronym.parameter, use: deleteHandler)
    acronymsRoute.put(Acronym.parameter, use: updateHandler)
    acronymsRoute.get(Acronym.parameter, "user", use: getUserHandler)
  }
  
  func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
    return Acronym.query(on: req).all()
  }
  
  func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
    return acronym.save(on: req)
  }
  
  func getHandler(_ req: Request) throws -> Future<Acronym> {
    return try req.parameters.next(Acronym.self)
  }
  
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Acronym.self).flatMap(to: HTTPStatus.self) { acronym in
      return acronym.delete(on: req).transform(to: HTTPStatus.noContent)
    }
  }
  
  func updateHandler(_ req: Request) throws -> Future<Acronym> {
    return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) { acronym, updatedAcronym in
      acronym.short = updatedAcronym.short
      acronym.long = updatedAcronym.long
      return acronym.save(on: req)
    }
  }
  
  func getUserHandler(_ req: Request) throws -> Future<User> {
    return try req.parameters.next(Acronym.self).flatMap(to: User.self) { acronym in
      return acronym.user.get(on: req)
    }
  }
}
