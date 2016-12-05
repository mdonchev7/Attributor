//
//  ViewController.m
//  Attributor
//
//  Created by Mincho Dzhagalov on 4/10/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "AttributorViewController.h"

@interface AttributorViewController ()
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UIButton *outlineButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@end

@implementation AttributorViewController

- (IBAction)analyzeText:(UIBarButtonItem *)sender {
    NSAttributedString *charactersWithStrokeAttribute = [self charactersWithAttribute:NSStrokeWidthAttributeName];
    NSAttributedString *charactersWithForegroundColorAttribute = [self charactersWithAttribute:NSForegroundColorAttributeName];
    
    NSString *message =
    [NSString stringWithFormat:@"Characters with stroke attribute: %lu\nCharacters with foreground color attribute: %lu",
                         (unsigned long)[charactersWithStrokeAttribute length],
                         (unsigned long)[charactersWithForegroundColorAttribute length]];
    
    UIAlertController *alert=   [UIAlertController
                                  alertControllerWithTitle:@"Results"
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler: ^(UIAlertAction * action) {[self dismissViewControllerAnimated:alert completion:nil];
}];
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSAttributedString *)charactersWithAttribute:(NSString *)attributeName
{
    NSMutableAttributedString *characters = [[NSMutableAttributedString alloc] init];
    
    NSMutableAttributedString *textToAnalyze = self.body.textStorage;
    
    NSRange range;
    int index = 0;
    
    while (index < [textToAnalyze length]) {
        id value = [textToAnalyze attribute:attributeName atIndex:index effectiveRange:&range];
        if (value) {
            [characters appendAttributedString:[textToAnalyze attributedSubstringFromRange:range]];
            index = range.location + range.length;
        } else {
            index++;
        }
    }
    
    return  characters;
}

- (IBAction)outlineSelection {
    [self.body.textStorage addAttributes:@{ NSStrokeWidthAttributeName:@-3,
                                            NSStrokeColorAttributeName:[UIColor blackColor] }
                                   range:self.body.selectedRange];
}

- (IBAction)unoutlineSelection {
    [self.body.textStorage removeAttribute:NSStrokeWidthAttributeName
                                     range:self.body.selectedRange];
}

- (IBAction)changeSelectionColorToMatchButtonBackground:(UIButton *)sender {
    [self.body.textStorage addAttribute:NSForegroundColorAttributeName
                                    value:sender.backgroundColor
                                    range:self.body.selectedRange];
}

- (void)usePreferredFonts
{
    self.body.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self.navigationBar setTitleTextAttributes:@{ NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] }];
}

- (void)preferredFontsChanged:(NSNotification *)notification
{
    [self usePreferredFonts];
}

#pragma mark Delegate Methods

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark View Controller Lifecycle Methods

- (void)viewWillAppear:(BOOL)aniemated
{
    [super viewWillAppear:aniemated];
    
    [self usePreferredFonts];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredFontsChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:self.outlineButton.currentTitle];
    [title setAttributes:@{ NSStrokeWidthAttributeName: @3,
                            NSStrokeColorAttributeName: self.outlineButton.tintColor }
                   range:NSMakeRange(0, [title length])];
    [self.outlineButton setAttributedTitle:title forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

@end
