const functions = require("firebase-functions/v2");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNewMessageNotification = functions.firestore
  .onDocumentCreated('chat/{chatId}/messages/{messageId}', async (event) => {
    const snap = event.data;

    if (!snap) {
      logger.error('No data in event.');
      return;
    }

    const message = snap.data();

    const receiverID = message.receiverID;
    const senderID = message.senderID;
    const text = message.text;
    logger.info(`Sender and reciever  :   ${senderID}   =============== ${receiverID}`);
    // Get receiver's FCM token(s)
    const tokensQuery = await admin.firestore()
      .collection('tokens')
      .where('userID', '==', receiverID)
      .get();

    if (tokensQuery.empty) {
      logger.info(`No FCM token for user ${receiverID}`);
      return;
    }

    const tokens = tokensQuery.docs.map(doc => doc.id);
    logger.info(`Sending notification to tokens: ${tokens}`);

    const payload = {
      notification: {
        title: 'New Message',
        body: text,
      },
      data: {
        senderID: senderID,
        receiverID: receiverID,
      },
      tokens: tokens  // << This is NOT part of payload for `send()`
    };

    const messageObj = {
      tokens: tokens,
      notification: {
        title: 'New Message',
        body: text
      },
      data: {
        senderID: senderID,
        receiverID: receiverID
      }
    };

    await admin.messaging().sendEachForMulticast(messageObj);

    logger.info(`Notification sent to receiverID: ${receiverID}`);
  });


exports.sendAppointmentsBooking = functions.firestore
  .onDocumentCreated('appointments/{appointmentsId}', async (event) => {
    const snap = event.data;

    if (!snap) {
      logger.error('No data in event.');
      return;
    }

    const message = snap.data();

    const craftsmanID = message.craftsman_id;
    // Get receiver's FCM token(s)
    const tokensQuery = await admin.firestore()
      .collection('tokens')
      .where('userID', '==', craftsmanID)
      .get();

    if (tokensQuery.empty) {
      logger.info(`No FCM token for user ${receiverID}`);
      return;
    }

    const tokens = tokensQuery.docs.map(doc => doc.id);
    logger.info(`Sending notification to tokens: ${tokens}`);

    const payload = {
      notification: {
        title: 'Appointment Booked',
        body: 'You have recieved a new appointment',
      },
      data: {
        craftsmanID: craftsmanID,
      },
      tokens: tokens  // << This is NOT part of payload for `send()`
    };

    const messageObj = {
      tokens: tokens,
      notification: {
        title: 'Appointment Booked',
        body: 'You have recieved a new appointment'
      },
      data: {
        craftsmanID: craftsmanID
      }
    };

    await admin.messaging().sendEachForMulticast(messageObj);

  });
