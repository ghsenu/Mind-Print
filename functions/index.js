const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

function queueNotification(doc, title, body, type) {
	const notificationRef = doc.ref.collection('notifications').doc();
	return notificationRef.set({
		userId: doc.id,
		title,
		body,
		type,
		isRead: false,
		createdAt: admin.firestore.FieldValue.serverTimestamp(),
	});
}

exports.sendDailyAffirmation = functions.pubsub
	.schedule('0 8 * * *')
	.timeZone('Asia/Colombo')
	.onRun(async () => {
		const usersSnapshot = await admin.firestore().collection('users').get();
		const messages = [];
		const writes = [];

		usersSnapshot.forEach((doc) => {
			const user = doc.data();
			if (!user.fcmToken) return;

			const title = 'Morning Affirmation';
			const body = 'Take a deep breath and have a great day ahead!';

			messages.push({
				token: user.fcmToken,
				notification: { title, body },
			});
			writes.push(queueNotification(doc, title, body, 'affirmation'));
		});

		if (messages.length > 0) {
			await admin.messaging().sendEachForMulticast({ tokens: messages.map((message) => message.token), notification: messages[0].notification });
			await Promise.all(writes);
			console.log(`Sent affirmations to ${messages.length} users.`);
		}

		return null;
	});

exports.sendJournalReminder = functions.pubsub
	.schedule('0 19 * * *')
	.timeZone('Asia/Colombo')
	.onRun(async () => {
		const usersSnapshot = await admin.firestore().collection('users').get();
		const messages = [];
		const writes = [];

		const today = new Date();
		today.setHours(0, 0, 0, 0);

		for (const doc of usersSnapshot.docs) {
			const user = doc.data();
			if (!user.fcmToken) continue;

			const journalsSnapshot = await doc.ref
				.collection('journals')
				.where('createdAt', '>=', admin.firestore.Timestamp.fromDate(today))
				.limit(1)
				.get();

			if (journalsSnapshot.empty) {
				const title = 'Evening Reflection';
				const body = 'How was your day? Take a moment to log your journal.';

				messages.push({
					token: user.fcmToken,
					notification: { title, body },
				});
				writes.push(queueNotification(doc, title, body, 'reminder'));
			}
		}

		if (messages.length > 0) {
			await admin.messaging().sendEachForMulticast({ tokens: messages.map((message) => message.token), notification: messages[0].notification });
			await Promise.all(writes);
			console.log(`Sent journal reminders to ${messages.length} users.`);
		}

		return null;
	});