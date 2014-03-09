//
//  DHError.m
//  TMTimer
//
//  Created by Derrick Ho on 3/9/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHError.h"

@implementation DHError
+ (void)displayValidationError:(NSError *)anError {
	if (anError && [[anError domain] isEqualToString:@"NSCocoaErrorDomain"]) {
		NSArray *errors = nil;
		
		// multiple errors?
		if ([anError code] == NSValidationMultipleErrorsError) {
			errors = [[anError userInfo] objectForKey:NSDetailedErrorsKey];
		} else {
			errors = [NSArray arrayWithObject:anError];
		}
		
		if (errors && [errors count] > 0) {
			NSString *messages = @"Reason(s):\n";
			
			for (NSError * error in errors) {
				NSString *entityName = [[[[error userInfo] objectForKey:@"NSValidationErrorObject"] entity] name];
				NSString *attributeName = [[error userInfo] objectForKey:@"NSValidationErrorKey"];
				NSString *msg;
				switch ([error code]) {
					case NSManagedObjectValidationError:
						msg = @"Generic validation error.";
						break;
					case NSValidationMissingMandatoryPropertyError:
						msg = [NSString stringWithFormat:@"The attribute '%@' mustn't be empty.", attributeName];
						break;
					case NSValidationRelationshipLacksMinimumCountError:
						msg = [NSString stringWithFormat:@"The relationship '%@' doesn't have enough entries.", attributeName];
						break;
					case NSValidationRelationshipExceedsMaximumCountError:
						msg = [NSString stringWithFormat:@"The relationship '%@' has too many entries.", attributeName];
						break;
					case NSValidationRelationshipDeniedDeleteError:
						msg = [NSString stringWithFormat:@"To delete, the relationship '%@' must be empty.", attributeName];
						break;
					case NSValidationNumberTooLargeError:
						msg = [NSString stringWithFormat:@"The number of the attribute '%@' is too large.", attributeName];
						break;
					case NSValidationNumberTooSmallError:
						msg = [NSString stringWithFormat:@"The number of the attribute '%@' is too small.", attributeName];
						break;
					case NSValidationDateTooLateError:
						msg = [NSString stringWithFormat:@"The date of the attribute '%@' is too late.", attributeName];
						break;
					case NSValidationDateTooSoonError:
						msg = [NSString stringWithFormat:@"The date of the attribute '%@' is too soon.", attributeName];
						break;
					case NSValidationInvalidDateError:
						msg = [NSString stringWithFormat:@"The date of the attribute '%@' is invalid.", attributeName];
						break;
					case NSValidationStringTooLongError:
						msg = [NSString stringWithFormat:@"The text of the attribute '%@' is too long.", attributeName];
						break;
					case NSValidationStringTooShortError:
						msg = [NSString stringWithFormat:@"The text of the attribute '%@' is too short.", attributeName];
						break;
					case NSValidationStringPatternMatchingError:
						msg = [NSString stringWithFormat:@"The text of the attribute '%@' doesn't match the required pattern.", attributeName];
						break;
					default:
						msg = [NSString stringWithFormat:@"Unknown error (code %ld).", (long)[error code]];
						break;
				}
				
				messages = [messages stringByAppendingFormat:@"%@%@%@\n", (entityName?:@""),(entityName?@": ":@""),msg];
			}
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation Error"
																											message:messages
																										 delegate:nil
																						cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[alert show];
			abort();
		}
	}
}
@end
