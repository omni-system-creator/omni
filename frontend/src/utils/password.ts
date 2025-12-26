export const generatePassword = (length = 12): string => {
  const lower = "abcdefghijklmnopqrstuvwxyz";
  const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const number = "0123456789";
  
  const all = lower + upper + number;
  
  let password = "";
  // Ensure at least one of each
  password += lower.charAt(Math.floor(Math.random() * lower.length));
  password += upper.charAt(Math.floor(Math.random() * upper.length));
  password += number.charAt(Math.floor(Math.random() * number.length));
  
  // Fill the rest
  for (let i = 3; i < length; i++) {
    password += all.charAt(Math.floor(Math.random() * all.length));
  }
  
  // Shuffle
  return password.split('').sort(() => 0.5 - Math.random()).join('');
};
