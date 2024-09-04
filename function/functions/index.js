const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendChatNotification = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const messageData = snapshot.data();

    // 메시지를 보낸 사용자 ID
    const senderId = messageData.senderId;

    // 채팅방 ID
    const chatId = context.params.chatId;

    // 채팅방 정보를 가져옴
    const chatDoc = await admin.firestore().collection("chats")
      .doc(chatId).get();
    const chatData = chatDoc.data();

    // 메시지를 보낸 사용자의 username 가져옴
    const senderDoc = await admin.firestore().collection("user")
      .doc(senderId).get();
    const senderData = senderDoc.data();
    const senderUsername = senderData.username;

    // 메시지 내용 가져옴
    const messageText = messageData.text;

    // 채팅방 참여자 리스트
    const participants = chatData.participants;

    // 메시지를 보낸 사용자를 제외한 나머지 사용자들에게 알림을 생성
    for (const participant of participants) {
      if (participant !== senderId) {
        const userDoc = await admin.firestore().collection("user")
          .doc(participant).get();
        const userData = userDoc.data();
        if (userData) {
          // 알림 저장
          await admin.firestore().collection("alarms")
            .doc(participant).collection("userAlarms").add({
              "alarmType": "chat",
              "message": `${senderUsername} : ${messageText}`, // 알림 내용 수정
              "timestamp": admin.firestore.FieldValue.serverTimestamp(),
              "chatId": chatId,
              "senderId": senderId,
              "read": false, // 새로운 알림은 읽지 않은 상태로 설정
            });

          // 알람 상태 업데이트
          await admin.firestore().collection("alarms").doc(participant).set({
            "hasNewChat": true,
          }, { merge: true });
        }
      }
    }

    console.log("알림 저장 완료");
  });

//새로운 채팅이 왔는지 확인하고 트리거
  exports.updateHasNewChat = functions.firestore
    .document('chats/{chatId}/messages/{messageId}')
    .onCreate(async (snapshot, context) => {
        const messageData = snapshot.data();
        const senderId = messageData.senderId;
        const chatId = context.params.chatId;

        // 채팅방 정보를 가져옴
        const chatDoc = await admin.firestore().collection('chats').doc(chatId).get();
        const chatData = chatDoc.data();
        const participants = chatData.participants;

        const unreadParticipants = participants.filter(participant => {
            return !chatData.lastMessageReadBy.includes(participant) && participant !== senderId;
        });

        if (unreadParticipants.length > 0) {
            const batch = admin.firestore().batch();

            unreadParticipants.forEach(participant => {
                const alarmDocRef = admin.firestore().collection('alarms').doc(participant);
                batch.set(alarmDocRef, { hasNewChat: true }, { merge: true });
            });

            await batch.commit();
            console.log('hasNewChat updated for unread participants');
        } else {
            console.log('All participants have read the message or sender is the only participant');
        }
    });
//모든 채팅방을 확인하여 읽지 않은 메시지가 있는지 확인
    exports.markMessageAsRead = functions.firestore
    .document('chats/{chatId}')
    .onUpdate(async (change, context) => {
        const beforeData = change.before.data();
        const afterData = change.after.data();

        const lastMessageReadByBefore = beforeData.lastMessageReadBy || [];
        const lastMessageReadByAfter = afterData.lastMessageReadBy || [];

        // 메시지를 읽은 사용자를 찾음
        const newReaders = lastMessageReadByAfter.filter(userId => !lastMessageReadByBefore.includes(userId));

        if (newReaders.length > 0) {
            const batch = admin.firestore().batch();

            for (const userId of newReaders) {
                // 모든 채팅방을 확인하여 읽지 않은 메시지가 있는지 확인
                const chatDocs = await admin.firestore().collection('chats')
                    .where('participants', 'array-contains', userId)
                    .get();

                let hasUnreadMessages = false;

                for (const chatDoc of chatDocs.docs) {
                    const chatData = chatDoc.data();
                    if (!chatData.lastMessageReadBy.includes(userId)) {
                        hasUnreadMessages = true;
                        break;
                    }
                }

                // 읽지 않은 메시지가 없다면 hasNewChat을 false로 설정
                if (!hasUnreadMessages) {
                    const alarmDocRef = admin.firestore().collection('alarms').doc(userId);
                    batch.set(alarmDocRef, { hasNewChat: false }, { merge: true });
                }
            }

            await batch.commit();
            console.log('hasNewChat updated for users with no unread messages');
        } else {
            console.log('No new readers found');
        }
    });

 
// 공고 상태가 변경될 때 알림 생성
exports.onPostStatusChanged = functions.firestore
    .document('posts/{postId}')
    .onUpdate(async (change, context) => {
        const beforeData = change.before.data();
        const afterData = change.after.data();
        const postId = context.params.postId;

        try {
            // 1. 상태 변경이 발생했을 때
            const seniorUid = afterData.seniorUid;

            if (afterData.status === 'matched') {
                // 상태가 'matched'로 변경되었을 때
                const matesSnapshot = await admin.firestore()
                    .collection('posts')
                    .doc(postId)
                    .collection('mates')
                    .get();

                matesSnapshot.forEach(async mateDoc => {
                    const mateUid = mateDoc.data().mateUid;

                    // mateUid에게 알림 생성
                    await admin.firestore().collection('alarms')
                        .doc(mateUid)
                        .collection('userAlarms')
                        .add({
                            "alarmType": "post",
                            "message": "축하합니다! 신청하신 공고가 매칭되었습니다. 함께 활동을 시작해보세요!",
                            "timestamp": admin.firestore.FieldValue.serverTimestamp(),
                            "postId": postId,
                            "status": afterData.status,
                            "read": false,
                        });

                    console.log(`matched 알림 생성 완료: [postId: ${postId}, mateUid: ${mateUid}]`);
                });

                // seniorUid에게 알림 생성
                await admin.firestore().collection('alarms')
                    .doc(seniorUid)
                    .collection('userAlarms')
                    .add({
                        "alarmType": "post",
                        "message": "매칭이 완료되었습니다! 메이트와 함께 활동을 진행해보세요.",
                        "timestamp": admin.firestore.FieldValue.serverTimestamp(),
                        "postId": postId,
                        "status": afterData.status,
                        "read": false,
                    });

                console.log(`매칭 알림 생성 완료: [postId: ${postId}, seniorUid: ${seniorUid}]`);
            }

            // 2. 상태가 'activated', 'finished', 'failed'로 변경될 때
            if (['activated', 'finished', 'failed'].includes(afterData.status)) {
                const statusMessages = {
                    'activated': "활동이 시작되었습니다! 성공적인 활동을 응원합니다.",
                    'finished': "활동이 완료되었습니다! 활동을 통해 좋은 경험을 하셨기를 바랍니다.",
                    'failed': "안타깝게도 활동이 실패로 종료되었습니다. 다음엔 더 좋은 기회가 있을 거예요."
                };

                // seniorUid에게 알림 생성
                await admin.firestore().collection('alarms')
                    .doc(seniorUid)
                    .collection('userAlarms')
                    .add({
                        "alarmType": "post",
                        "message": statusMessages[afterData.status],
                        "timestamp": admin.firestore.FieldValue.serverTimestamp(),
                        "postId": postId,
                        "status": afterData.status,
                        "read": false,
                    });

                console.log(`상태 변경 알림 생성 완료 (seniorUid): [postId: ${postId}, status: ${afterData.status}, seniorUid: ${seniorUid}]`);

                // mateUid에게 알림 생성
                const matesSnapshot = await admin.firestore()
                    .collection('posts')
                    .doc(postId)
                    .collection('mates')
                    .get();

                matesSnapshot.forEach(async mateDoc => {
                    const mateUid = mateDoc.data().mateUid;

                    await admin.firestore().collection('alarms')
                        .doc(mateUid)
                        .collection('userAlarms')
                        .add({
                            "alarmType": "post",
                            "message": statusMessages[afterData.status],
                            "timestamp": admin.firestore.FieldValue.serverTimestamp(),
                            "postId": postId,
                            "status": afterData.status,
                            "read": false,
                        });

                    console.log(`상태 변경 알림 생성 완료 (mateUid): [postId: ${postId}, status: ${afterData.status}, mateUid: ${mateUid}]`);
                });
            }
        } catch (error) {
            console.error(`Error processing status change for postId: ${postId}`, error);
        }
    });

// 'mates' 문서 추가 또는 업데이트 시 알림 생성
exports.onMateAddedOrUpdated = functions.firestore
    .document('posts/{postId}/mates/{mateId}')
    .onWrite(async (change, context) => {
        const postId = context.params.postId;
        const mateUid = context.params.mateId;

        try {
            const postDoc = await admin.firestore().collection('posts').doc(postId).get();
            const postData = postDoc.data();
            const seniorUid = postData.seniorUid;

            // seniorUid에게 알림 생성
            await admin.firestore().collection('alarms')
                .doc(seniorUid)
                .collection('userAlarms')
                .add({
                  "alarmType": "post", 
                  "message": "새로운 메이트가 공고에 신청했습니다! 지금 확인해보세요.",
                  "timestamp": admin.firestore.FieldValue.serverTimestamp(),
                  "postId": postId,
                  "mateUid": mateUid,
                  "status": 'notMatched',
                  "read": false,
                });

            console.log(`새로운 메이트 신청 알림 생성 완료: [postId: ${postId}, seniorUid: ${seniorUid}]`);
        } catch (error) {
            console.error(`Error processing mate addition/update for postId: ${postId}`, error);
        }
    });

// 'userAlarms' 컬렉션의 문서가 생성되거나 업데이트될 때, 읽지 않은 알림이 있는지 확인하고 hasNewAlarms 업데이트
exports.updateHasNewAlarms = functions.firestore
  .document('alarms/{userId}/userAlarms/{alarmId}')
  .onWrite(async (change, context) => {
    const userId = context.params.userId;

    try {
      // 1. 사용자의 알림 컬렉션을 가져옴
      const userAlarmsSnapshot = await admin.firestore()
        .collection('alarms')
        .doc(userId)
        .collection('userAlarms')
        .get();

      let hasUnreadAlarms = false;

      // 2. 각 알림의 'read' 필드를 확인
      userAlarmsSnapshot.forEach(doc => {
        const alarmData = doc.data();
        if (!alarmData.read) {
          hasUnreadAlarms = true;
        }
      });

      // 3. hasUnreadAlarms 값에 따라 hasNewAlarms 필드를 업데이트
      await admin.firestore().collection('alarms').doc(userId).set({
        "hasNewAlarms": hasUnreadAlarms,
      }, { merge: true });

      console.log(`hasNewAlarms 상태 업데이트 완료: [userId: ${userId}, hasNewAlarms: ${hasUnreadAlarms}]`);
    } catch (e) {
      console.error(`Error updating hasNewAlarms for user ${userId}: `, e);
    }
  });