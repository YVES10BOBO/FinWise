// Profile picture upload was removed before the Play Store release.
//
// Why:
//  • Firebase Storage now requires the paid Blaze plan, so uploads could not
//    work on the free Spark plan the app runs on.
//  • Photo collection had already been flagged during Play review.
//  • Dropping it removes the CAMERA and photo permissions entirely, which
//    simplifies both the permissions review and the Data Safety declaration
//    (the app now collects no photos at all).
//
// Users get an avatar showing the first letter of their name instead — see
// widgets/personalized_header.dart.
//
// This file is intentionally left empty rather than deleted so the change is
// self-documenting. It is safe to delete.
