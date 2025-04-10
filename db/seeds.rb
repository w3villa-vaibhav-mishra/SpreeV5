# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Spree::Core::Engine.load_seed if defined?(Spree::Core)
puts "🌱 Seeding 5 smartphone products..."

shipping_category = Spree::ShippingCategory.first_or_create!(name: 'Default')

products = [
  { name: "iPhone 15 Pro", price: 1199.0, sku: "IPH15PRO", description: "A17 Bionic chip, ProMotion, 128GB" },
  { name: "Pixel 8 Pro", price: 999.0, sku: "PIX8PRO", description: "Tensor G3, clean Android, 6.7-inch display" },
  { name: "OnePlus 12", price: 899.0, sku: "OP12", description: "Snapdragon 8 Gen 3, 120Hz AMOLED" },
  { name: "Nothing Phone 2", price: 699.0, sku: "NP2", description: "Glyph interface, Snapdragon 8+" },
  { name: "Asus ROG Phone 7", price: 1099.0, sku: "ROG7", description: "Gaming beast with AirTriggers" }
]

products.each do |attrs|
  product = Spree::Product.find_or_initialize_by(name: attrs[:name])
  product.assign_attributes(
    price: attrs[:price],
    description: attrs[:description],
    available_on: Time.current - 1.day,
    shipping_category: shipping_category,
    status: "active"
  )

  if product.save
    # Set SKU on master variant
    product.master.update!(sku: attrs[:sku])

    # Add stock
    stock_location = Spree::StockLocation.first_or_create!(name: 'default', propagate_all_variants: true)
    product.master.stock_items.each do |stock_item|
      stock_item.set_count_on_hand(10)
    end

    puts "✅ Created or updated: #{product.name}"
  else
    puts "❌ Failed to create #{attrs[:name]} — #{product.errors.full_messages.join(', ')}"
  end
end
