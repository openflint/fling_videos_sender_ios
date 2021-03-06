//
// Created by Jiang Lu on 14-4-1.
// Copyright (C) 2013-2014, Infthink (Beijing) Technology Co., Ltd.
//

@class MSFKImage;

/** @cond INTERNAL */

typedef NS_ENUM(NSInteger, MSFKMediaMetadataType) {
    /** A media type representing generic media content. */
    MSFKMediaMetadataTypeGeneric = 0,
    /** A media type representing a movie. */
    MSFKMediaMetadataTypeMovie = 1,
    /** A media type representing an TV show. */
    MSFKMediaMetadataTypeTVShow = 2,
    /** A media type representing a music track. */
    MSFKMediaMetadataTypeMusicTrack = 3,
    /** A media type representing a photo. */
    MSFKMediaMetadataTypePhoto = 4,
    /** The smallest media type value that can be assigned for application-defined media types. */
    MSFKMediaMetadataTypeUser = 100,
};

/** @endcond */


/**
 * String key: Creation date.
 * <p>
 * The value is the date and/or time at which the media was created, in ISO-8601 format.
 * For example, this could be the date and time at which a photograph was taken or a piece of
 * music was recorded.
 */
extern NSString *const kMSFKMetadataKeyCreationDate;

/**
 * String key: Release date.
 * <p>
 * The value is the date and/or time at which the media was released, in ISO-8601 format.
 * For example, this could be the date that a movie or music album was released.
 */
extern NSString *const kMSFKMetadataKeyReleaseDate;

/**
 * String key: Broadcast date.
 * <p>
 * The value is the date and/or time at which the media was first broadcast, in ISO-8601 format.
 * For example, this could be the date that a TV show episode was first aired.
 */
extern NSString *const kMSFKMetadataKeyBroadcastDate;

/**
 * String key: Title.
 * <p>
 * The title of the media. For example, this could be the title of a song, movie, or TV show
 * episode. This value is suitable for display purposes.
 */
extern NSString *const kMSFKMetadataKeyTitle;

/**
 * String key: Subtitle.
 * <p>
 * The subtitle of the media. This value is suitable for display purposes.
 */
extern NSString *const kMSFKMetadataKeySubtitle;

/**
 * String key: Artist.
 * <p>
 * The name of the artist who created the media. For example, this could be the name of a
 * musician, performer, or photographer. This value is suitable for display purposes.
 */
extern NSString *const kMSFKMetadataKeyArtist;

/**
 * String key: Album artist.
 * <p>
 * The name of the artist who produced an album. For example, in compilation albums such as DJ
 * mixes, the album artist is not necessarily the same as the artist(s) of the individual songs
 * on the album. This value is suitable for display purposes.
 */
extern NSString *const kMSFKMetadataKeyAlbumArtist;

/**
 * String key: Album title.
 * <p>
 * The title of the album that a music track belongs to. This value is suitable for display
 * purposes.
 */
extern NSString *const kMSFKMetadataKeyAlbumTitle;

/**
 * String key: Composer.
 * <p>
 * The name of the composer of a music track. This value is suitable for display purposes.
 */
extern NSString *const kMSFKMetadataKeyComposer;

/**
 * Integer key: Disc number.
 * <p>
 * The disc number (counting from 1) that a music track belongs to in a multi-disc album.
 */
extern NSString *const kMSFKMetadataKeyDiscNumber;

/**
 * Integer key: Track number.
 * <p>
 * The track number of a music track on an album disc. Typically track numbers are counted
 * starting from 1, however this value may be 0 if it is a "hidden track" at the beginning of
 * an album.
 */
extern NSString *const kMSFKMetadataKeyTrackNumber;

/**
 * Integer key: Season number.
 * <p>
 * The season number that a TV show episode belongs to. Typically season numbers are counted
 * starting from 1, however this value may be 0 if it is a "pilot" episode that predates the
 * official start of a TV series.
 */
extern NSString *const kMSFKMetadataKeySeasonNumber;

/**
 * Integer key: Episode number.
 * <p>
 * The number of an episode in a given season of a TV show. Typically episode numbers are
 * counted starting from 1, however this value may be 0 if it is a "pilot" episode that is not
 * considered to be an official episode of the first season.
 */
extern NSString *const kMSFKMetadataKeyEpisodeNumber;

/**
 * String key: Series title.
 * <p>
 * The name of a series. For example, this could be the name of a TV show or series of related
 * music albums. This value is suitable for display purposes.
 */
extern NSString *const kMSFKMetadataKeySeriesTitle;

/**
 * String key: Studio.
 * <p>
 * The name of a recording studio that produced a piece of media. For example, this could be
 * the name of a movie studio or music label. This value is suitable for display purposes.
 */
extern NSString *const kMSFKMetadataKeyStudio;

/**
 * Integer key: Width.
 *
 * The width of a piece of media, in pixels. This would typically be used for providing the
 * dimensions of a photograph.
 */
extern NSString *const kMSFKMetadataKeyWidth;

/**
 * Integer key: Height.
 *
 * The height of a piece of media, in pixels. This would typically be used for providing the
 * dimensions of a photograph.
 */
extern NSString *const kMSFKMetadataKeyHeight;

/**
 * String key: Location name.
 * <p>
 * The name of a location where a piece of media was created. For example, this could be the
 * location of a photograph or the principal filming location of a movie. This value is
 * suitable for display purposes.
 */
extern NSString *const kMSFKMetadataKeyLocationName;

/**
 * Double key: Location latitude.
 * <p>
 * The latitude component of the geographical location where a piece of media was created.
 * For example, this could be the location of a photograph or the principal filming location of
 * a movie.
 */
extern NSString *const kMSFKMetadataKeyLocationLatitude;

/**
 * Double key: Location longitude.
 * <p>
 * The longitude component of the geographical location where a piece of media was created.
 * For example, this could be the location of a photograph or the principal filming location of
 * a movie.
 */
extern NSString *const kMSFKMetadataKeyLocationLongitude;


/**
 * Container class for media metadata. Metadata has a media type, an optional
 * list of images, and a collection of metadata fields. Keys for common
 * metadata fields are predefined as constants, but the application is free to
 * define and use additional fields of its own.
 * <p>
 * The values of the predefined fields have predefined types. For example, a track number is
 * an <code>NSInteger</code> and a creation date is a <code>NSString</code> containing an ISO-8601
 * representation of a date and time. Attempting to store a value of an incorrect type in a field
 * will assert.
 * <p>
 * Note that the Flint protocol limits which metadata fields can be used for a given media type.
 * When a MediaMetadata object is serialized to JSON for delivery to a Flint receiver, any
 * predefined fields which are not supported for a given media type will not be included in the
 * serialized form, but any application-defined fields will always be included.
 */
@interface MSFKMediaMetadata : NSObject

@property(nonatomic) MSFKMediaMetadataType metadataType;

/**
 * Initializes a new, empty, MediaMetadata with the given media type.
 * Designated initializer.
 *
 * @param metadataType The media type; one of the {@code MEDIA_TYPE_*} constants, or a value greater
 * than or equal to {@link MEDIA_TYPE_USER} for custom media types.
 */
- (id)initWithMetadataType:(MSFKMediaMetadataType)metadataType;

/**
 * Initialize with the generic metadata type.
 */
- (id)init;

/**
 * The metadata type.
 */
- (MSFKMediaMetadataType)metadataType;

/**
 * Gets the list of images.
 */
- (NSArray *)images;

/**
 * Removes all the current images.
 */
- (void)removeAllMediaImages;

/**
 * Adds an image to the list of images.
 */
- (void)addImage:(MSFKImage *)image;

/**
 * Tests if the object contains a field with the given key.
 */
- (BOOL)containsKey:(NSString *)key;

/**
 * Returns a set of keys for all fields that are present in the object.
 */
- (NSArray *)allKeys;

/**
 * Stores a value in a string field. Asserts if the key refers to a predefined field which is not a
 * {@code NSString} field.
 *
 * @param key The key for the field.
 * @param value The new value for the field.
 */
- (void)setString:(NSString *)value forKey:(NSString *)key;

/**
 * Reads the value of a string field. Asserts if the key refers to a predefined field which is not
 * a {@code NSString} field.
 *
 * @return The value of the field, or {@code nil} if the field has not been set.
 */
- (NSString *)stringForKey:(NSString *)key;

/**
 * Stores a value in an integer field. Asserts if the key refers to a predefined field which is
 * not an {@code NSInteger} field.
 *
 * @param key The key for the field.
 * @param value The new value for the field.
 */
- (void)setInteger:(NSInteger)value forKey:(NSString *)key;

/**
 * Reads the value of an integer field. Asserts if the key refers to a predefined field which is
 * not an {@code NSInteger} field.
 *
 * @return The value of the field, or 0 if the field has not been set.
 */
- (NSInteger)integerForKey:(NSString *)key;

/**
 * Reads the value of an integer field. Asserts if the key refers to a predefined field which is
 * not an {@code NSInteger} field.
 *
 * @param defaultValue The value to return if the field has not been set.
 * @return The value of the field, or the given default value if the field has not been set.
 */
- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;

/**
 * Stores a value in a {@code double} field. Asserts if the key refers to a predefined field
 * which is not a {@code double} field.
 *
 * @param key The key for the field.
 * @param value The new value for the field.
 */
- (void)setDouble:(double)value forKey:(NSString *)key;

/**
 * Reads the value of a {@code double} field. Asserts if the key refers to a predefined field
 * which is not a {@code double} field.
 *
 * @return The value of the field, or 0 if the field has not been set.
 */
- (double)doubleForKey:(NSString *)key;

/**
 * Reads the value of a {@code double} field. Asserts if the key refers to a predefined field
 * which is not a {@code double} field.
 *
 * @param defaultValue The value to return if the field has not been set.
 * @return The value of the field, or the given default value if the field has not been set.
 */
- (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue;

/**
 * Stores a value in a date field as a restricted ISO-8601 representation of the date. Asserts if
 * the key refers to a predefined field which is not a date field.
 *
 * @param key The key for the field.
 * @param value The new value for the field.
 */
- (void)setDate:(NSDate *)date forKey:(NSString *)key;

/**
 * Reads the value of a date field from the restricted ISO-8601 representation of the date.
 * Asserts if the key refers to a predefined field which is not a date field.
 *
 * @param key The field name.
 * @return The date, or {@code nil} if this field has not been set.
 */
- (NSDate *)dateForKey:(NSString *)key;

/**
 * Reads the value of a date field, as a string. Asserts if the key refers to a predefined field
 * which is not a date field.
 *
 * @param key The field name.
 * @return The date, as a {@code String} containing the restricted ISO-8601 representation of the
 * date, or {@code null} if this field has not been set.
 * @throw IllegalArgumentException If the specified field's predefined type is not a date.
 */
- (NSString *)dateAsStringForKey:(NSString *)key;

/** @cond INTERNAL */

/**
 * Initialize this object with its JSON representation.
 */
- (id)initWithJSONObject:(id)jsonObject;

+ (instancetype)metadataWithJSONObject:(id)jsonObject;

/**
 * Create a JSON object which can serialized with NSJSONSerialization to pass to the receiver.
 */
- (id)JSONObject;

/** @endcond */

@end