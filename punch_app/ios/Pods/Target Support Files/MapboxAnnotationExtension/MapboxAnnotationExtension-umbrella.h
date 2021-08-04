#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MGLCircleStyleAnnotation.h"
#import "MGLCircleStyleAnnotation_Private.h"
#import "MGLLineStyleAnnotation.h"
#import "MGLLineStyleAnnotation_Private.h"
#import "MGLPolygonStyleAnnotation.h"
#import "MGLPolygonStyleAnnotation_Private.h"
#import "MGLStyleAnnotation.h"
#import "MGLStyleAnnotation_Private.h"
#import "MGLSymbolStyleAnnotation.h"
#import "MGLSymbolStyleAnnotation_Private.h"
#import "MGLEnums+MGLAnnotationExtension.h"
#import "MGLStructs+MGLAnnotationExtension.h"
#import "UIColor+MGLAnnotationExtension.h"
#import "MGLAnnotationController.h"
#import "MGLAnnotationController_Private.h"
#import "MGLCircleAnnotationController.h"
#import "MGLLineAnnotationController.h"
#import "MGLPolygonAnnotationController.h"
#import "MGLSymbolAnnotationController.h"
#import "MapboxAnnotationExtension.h"
#import "MGLAnnotationLayerView.h"

FOUNDATION_EXPORT double MapboxAnnotationExtensionVersionNumber;
FOUNDATION_EXPORT const unsigned char MapboxAnnotationExtensionVersionString[];

