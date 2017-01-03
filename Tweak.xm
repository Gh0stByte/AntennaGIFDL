#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"

@interface RCGIFViewController : UIViewController
@property(assign, nonatomic) NSURL *mp4URL;
@end

#define SETUP_LONGPRESS_ONCONTROLLER UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)]; longPress.minimumPressDuration = 1.5; [self.view addGestureRecognizer:longPress];


%hook RCGIFViewController

-(void)viewDidLoad
{
	SETUP_LONGPRESS_ONCONTROLLER
	%orig;
}

%new
-(void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
	UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
		[sender setEnabled:YES];
        // Cancel button tappped.
		[self  dismissViewControllerAnimated:YES completion:^{
		}];
	}]];

	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Save Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		hud.label.text = @"Downloading";
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSLog(@"Downloading Started");
			NSURL  *url = self.mp4URL;
			NSData *urlData = [NSData dataWithContentsOfURL:url];
			if ( urlData )
			{
				NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString  *documentsDirectory = [paths objectAtIndex:0];

				NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"tempVideo.mp4"];

				dispatch_async(dispatch_get_main_queue(), ^{
					hud.label.text = @"Saving";
					[urlData writeToFile:filePath atomically:YES];
					NSLog(@"File Saved !");
					hud.label.text = @"Importing";
					[sender setEnabled:YES];
					NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
					NSString  *documentsDirectory = [paths objectAtIndex:0];
					[[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", documentsDirectory,@"tempVideo.mp4"]] completionBlock:^(NSURL *assetURL, NSError *error) {

						if(assetURL) {
							hud.label.text = @"DONE!";
							[hud hideAnimated:YES];
						} else {
							hud.label.text = @"ERROR. Try Again.";
						}
					}];


				});
			}

		});

		[self dismissViewControllerAnimated:YES completion:^{
			
		}];
	}]];

    // Present action sheet.
	[self presentViewController:actionSheet animated:YES completion:nil];
}


%end