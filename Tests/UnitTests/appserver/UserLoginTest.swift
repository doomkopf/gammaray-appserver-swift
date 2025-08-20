import XCTest

@testable import Gammaray

final class UserLoginTest: XCTestCase {
    func testLoginGeneratesSessionIdForUserIdAndPutsPersistentSession() async throws {
        actor UserSenderMock: UserSender {
            var putSession: GammarayPersistentSession?
            var putUserId: EntityId?

            func send(userId: EntityId, payload: String) {
            }

            func putUserSession(
                session: GammarayPersistentSession, userId: EntityId
            ) {
                putSession = session
                putUserId = userId
            }

            func removeUserSession(userId: EntityId) {
            }
        }

        let userSender = UserSenderMock()

        let subject = try UserLogin(
            userSender: userSender,
            scheduler: NoopScheduler(),
        )

        let expectedUserId = try EntityId("testId")

        let sessionId = await subject.login(
            userId: expectedUserId,
            persistentSession: NoopGammarayPersistentSession(),
        )

        let returnedUserId = await subject.getUserId(sessionId: sessionId)
        let userSenderPutSession = await userSender.putSession
        let userSenderPutUserId = await userSender.putUserId

        XCTAssertEqual(expectedUserId.value, returnedUserId?.value)
        XCTAssertEqual(expectedUserId.value, userSenderPutUserId?.value)
        XCTAssertNotNil(userSenderPutSession)
    }

    func testLogoutRemovesAllMappingsAlsoFromUserSender() async throws {
        actor UserSenderMock: UserSender {
            var removedUserId: EntityId?

            func send(userId: EntityId, payload: String) {
            }

            func putUserSession(
                session: GammarayPersistentSession, userId: EntityId
            ) {
            }

            func removeUserSession(userId: EntityId) {
                removedUserId = userId
            }
        }

        let userSender = UserSenderMock()

        let subject = try UserLogin(
            userSender: userSender,
            scheduler: NoopScheduler(),
        )

        let userId = try EntityId("testId")

        let sessionId = await subject.login(
            userId: userId, persistentSession: NoopGammarayPersistentSession())

        await subject.logout(userId: userId)

        let returnedUserId = await subject.getUserId(sessionId: sessionId)
        XCTAssertNil(returnedUserId)
        let userSenderRemovedUserId = await userSender.removedUserId
        XCTAssertEqual(userId.value, userSenderRemovedUserId?.value)
    }

    func testLogsOutSameIdBeforeLogin() async throws {
        actor UserSenderMock: UserSender {
            var removedUserId: EntityId?

            func send(userId: EntityId, payload: String) {
            }

            func putUserSession(
                session: GammarayPersistentSession, userId: EntityId
            ) {
            }

            func removeUserSession(userId: EntityId) {
                removedUserId = userId
            }
        }

        let userSender = UserSenderMock()

        let subject = try UserLogin(
            userSender: userSender,
            scheduler: NoopScheduler(),
        )

        let userId = try EntityId("testId")

        _ = await subject.login(
            userId: userId, persistentSession: NoopGammarayPersistentSession())
        _ = await subject.login(
            userId: userId, persistentSession: NoopGammarayPersistentSession())

        let userSenderRemovedUserId = await userSender.removedUserId

        XCTAssertEqual(userId.value, userSenderRemovedUserId?.value)
    }
}
