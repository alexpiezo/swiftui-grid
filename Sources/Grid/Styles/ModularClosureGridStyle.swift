import SwiftUI

/// Modular `Grid` style.
public struct ModularClosureGridStyle: GridStyle {
    public var columns: (GridPreferences)->Tracks
    public var rows: (GridPreferences)->Tracks
    public var axis: Axis
    public var spacing: CGFloat
    public var autoWidth: Bool = true
    public var autoHeight: Bool = true
        
    public init(_ axis: Axis = .vertical, columns: @escaping (GridPreferences)->Tracks, rows: @escaping (GridPreferences)->Tracks, spacing: CGFloat = 8) {
        self.columns = columns
        self.rows = rows
        self.axis = axis
        self.spacing = spacing
    }
    
    public func transform(preferences: inout GridPreferences, in size: CGSize) {
        let computedTracksCount = self.axis == .vertical ?
            tracksCount(
                tracks: self.columns(preferences),
                spacing: self.spacing,
                availableLength: size.width
            ) :
            tracksCount(
                tracks: self.rows(preferences),
                spacing: self.spacing,
                availableLength: size.height
            )
        
        let itemSize = CGSize(
            width: itemLength(
                tracks: self.columns(preferences),
                spacing: self.spacing,
                availableLength: size.width
            ),
            height: itemLength(
                tracks: self.rows(preferences),
                spacing: self.spacing,
                availableLength: size.height
            )
        )
        
        preferences = layoutPreferences(
            tracks: computedTracksCount,
            spacing: self.spacing,
            axis: self.axis,
            itemSize: itemSize,
            preferences: preferences
        )
    }
    
    private func layoutPreferences(tracks: Int, spacing: CGFloat, axis: Axis, itemSize: CGSize, preferences: GridPreferences) -> GridPreferences {
        var tracksLengths = Array(repeating: CGFloat(0.0), count: tracks)
        var newPreferences: GridPreferences = GridPreferences(items: [])
        
        preferences.items.forEach { preference in
            if let minValue = tracksLengths.min(), let indexMin = tracksLengths.firstIndex(of: minValue) {
                let itemSizeWidth = itemSize.width
                let itemSizeHeight = itemSize.height
                let width = axis == .vertical ? itemSizeWidth * CGFloat(indexMin) + CGFloat(indexMin) * spacing : tracksLengths[indexMin]
                let height = axis == .vertical ? tracksLengths[indexMin] : itemSizeHeight * CGFloat(indexMin) + CGFloat(indexMin) * spacing
        
                let origin = CGPoint(x: width, y: height)
                tracksLengths[indexMin] += (axis == .vertical ? itemSizeHeight : itemSizeWidth) + spacing
                
                newPreferences.merge(with:
                    GridPreferences(items: [GridPreferences.Item(
                        id: preference.id,
                        bounds: CGRect(origin: origin, size: CGSize(width: itemSizeWidth, height: itemSizeHeight))
                    )])
                )
            }
        }

        return newPreferences
    }
}
