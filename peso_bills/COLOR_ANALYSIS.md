# Philippine Peso Bill Color Analysis

This document identifies the dominant colors found in all bill images from `assets/images` (excluding `peso_logo.png`).

## Analysis Results

### 20 Peso Bill (Paper)
- **File**: `20pesos-640-1571047972.jpg`
- **Average Color**: `#917268` (RGB: 145, 114, 104) - Warm brown/beige
- **Dominant Colors**:
  1. `#201010` - Dark brown/black
  2. `#a0b0b0` - Light gray-blue
  3. `#b08070` - Warm brown
  4. `#b08050` - Orange-brown
  5. `#b0b0b0` - Light gray
- **Color Palette**: Warm earth tones (browns, beiges) with gray-blue accents

### 50 Peso Bill (Paper)
- **File**: `50.jpg`
- **Average Color**: `#c7b4b8` (RGB: 199, 180, 184) - Light pink-beige
- **Dominant Colors**:
  1. `#c0d0c0` - Light green-gray
  2. `#b0c0b0` - Muted green
  3. `#f0f0f0` - Off-white
  4. `#a0b0b0` - Light gray-blue
  5. `#b0c0c0` - Light blue-gray
- **Color Palette**: Soft pastels (pink-beige, green-gray, light blues)

### 100 Peso Bill (Paper)
- **File**: `100.avif` (format not supported by analyzer)
- **Note**: AVIF format requires special handling

### 100 Peso Bill (Polymer/New)
- **File**: `new-100.webp`
- **Average Color**: `#b2aaaa` (RGB: 178, 170, 170) - Light gray-beige
- **Dominant Colors**:
  1. `#e0e0d0` - Cream/off-white
  2. `#e0d0d0` - Light pink-beige
  3. `#e0e0e0` - Light gray
  4. `#807070` - Medium gray-brown
  5. `#808070` - Olive-gray
- **Color Palette**: Light, neutral tones (creams, light grays, beiges)

### 200 Peso Bill
- **File**: `200.jpg`
- **Average Color**: `#727371` (RGB: 114, 115, 113) - Medium gray
- **Dominant Colors**:
  1. `#000000` - Black
  2. `#201020` - Very dark purple-gray
  3. `#c0c0c0` - Light gray
  4. `#101010` - Very dark gray
  5. `#a0a0a0` - Medium gray
- **Color Palette**: Grayscale with dark tones (blacks, dark grays, light grays)

### 500 Peso Bill (Paper)
- **File**: `500.jpg`
- **Average Color**: `#33332f` (RGB: 51, 51, 47) - Very dark gray-green
- **Dominant Colors**:
  1. `#000000` - Black
  2. `#202020` - Dark gray
  3. `#101010` - Very dark gray
  4. `#000010` - Very dark blue-gray
  5. `#707060` - Olive-gray
- **Color Palette**: Very dark tones (blacks, dark grays, olive)

### 500 Peso Bill (Polymer/New)
- **File**: `new-500.webp`
- **Average Color**: `#71675a` (RGB: 113, 103, 90) - Warm gray-brown
- **Dominant Colors**:
  1. `#707060` - Olive-gray
  2. `#807060` - Brown-gray
  3. `#403030` - Dark brown
  4. `#101010` - Very dark gray
  5. `#100000` - Very dark red-brown
- **Color Palette**: Earth tones (browns, grays, olives)

### 1000 Peso Bill (Paper)
- **File**: `1000.webp`
- **Average Color**: `#9badc1` (RGB: 155, 173, 193) - Light blue-gray
- **Dominant Colors**:
  1. `#9090a0` - Blue-gray
  2. `#f0f0f0` - Off-white
  3. `#e0e0f0` - Very light blue
  4. `#c0d0f0` - Light blue
  5. `#d0d0f0` - Light blue-gray
- **Color Palette**: Cool blues and grays (light blues, blue-grays, whites)

### 1000 Peso Bill (Polymer/New)
- **File**: `new-1000.jpg`
- **Average Color**: `#9ca8b3` (RGB: 156, 168, 179) - Light blue-gray
- **Dominant Colors**:
  1. `#a0b0c0` - Light blue-gray
  2. `#c0c0d0` - Light blue
  3. `#b0b0c0` - Blue-gray
  4. `#608090` - Medium blue-gray
  5. `#a0b0b0` - Light gray-blue
- **Color Palette**: Cool blues and grays (similar to paper version but slightly different tones)

### 50 Peso Bill (Polymer/New)
- **File**: `new-50.jpg`
- **Average Color**: `#6e6359` (RGB: 110, 99, 89) - Warm brown-gray
- **Dominant Colors**:
  1. `#504030` - Dark brown
  2. `#a0c0d0` - Light blue
  3. `#606040` - Olive
  4. `#605040` - Brown
  5. `#403020` - Dark brown
- **Color Palette**: Earth tones with blue accents (browns, olives, light blues)

## Overall Color Patterns

### Common Colors Across All Bills:
- **Light Grays/Whites** (`#f0f0f0`, `#e0e0e0`): Appear in multiple bills, likely backgrounds
- **Blacks/Dark Grays** (`#000000`, `#101010`, `#202020`): Text and dark design elements
- **Blue-Grays** (`#a0b0b0`, `#9090a0`): Common in higher denominations (500, 1000)
- **Browns/Beiges**: Common in lower denominations (20, 50)

### Denomination-Specific Patterns:
- **20 Peso**: Warm earth tones (browns, beiges)
- **50 Peso**: Soft pastels (pink-beiges, green-grays)
- **100 Peso (New)**: Light, neutral tones (creams, light grays)
- **200 Peso**: Grayscale (blacks, grays)
- **500 Peso**: Dark tones (blacks, dark grays, olives)
- **1000 Peso**: Cool blues and grays

### Material Differences (Paper vs Polymer):
- **Polymer bills** tend to have:
  - Lighter, more neutral color palettes
  - More consistent color distribution
  - Cream/off-white backgrounds
  
- **Paper bills** tend to have:
  - More variation in color
  - Warmer tones in lower denominations
  - More contrast between light and dark areas

## Technical Notes

- Analysis performed using pixel sampling (every Nth pixel for performance)
- Colors are quantized to reduce noise (grouped into 16-level bins)
- AVIF format (`100.avif`) is not supported by the current image library
- Percentages shown are relative to sampled pixels, not total image pixels







