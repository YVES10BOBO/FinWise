// This helper is no longer used. SMS detections are now recorded through a
// single path in `services/sms_listener_service.dart` (`_processSms`) and
// drained into the live list by `TransactionProvider.refreshFromCache()`.
// Left intentionally empty to avoid any dangling references; safe to delete.
