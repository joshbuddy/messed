describe __APP_NAME__ do
  it "should have a test" do
    process('this is my message')
    should_say "well, that was fun"
  end
end