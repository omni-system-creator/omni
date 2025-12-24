import CryptoJS from 'crypto-js'
import { decrypt as aesDecrypt, encrypt as aesEncrypt } from 'crypto-js/aes';
import { isString } from './type'
import CTR from 'crypto-js/mode-ctr';
import pkcs7 from 'crypto-js/pad-pkcs7';
import UTF8, { parse } from 'crypto-js/enc-utf8';

const KEY = 'mt'

export const myDecrypt = (cipherText: string) :string => {
  const options = {
    mode: CTR,
    padding: pkcs7,
    iv: parse('@11111000001111_'),
  };
  return aesDecrypt(cipherText, parse('_11111000001111@'), options).toString(UTF8);
}

/**
 * * 加密
 * @param data { string }
 * @returns 
 */
export const cryptoEncode = (data: string): string => {
  if (!isString(data)) return ''
  // 加密
  const encryptedData = CryptoJS.AES.encrypt(data, KEY, {
    mode: CryptoJS.mode.ECB,
    padding: CryptoJS.pad.Pkcs7
  }).toString()
  return encryptedData
}

/**
 * * 解密
 * @param data { string }
 * @returns 
 */
export const cryptoDecode = (data: string): string => {
  if (!isString(data)) return ''
  // 解密
  const decryptedData = CryptoJS.AES.decrypt(data, KEY, {
    mode: CryptoJS.mode.ECB,
    padding: CryptoJS.pad.Pkcs7
  })
  return decryptedData.toString(CryptoJS.enc.Utf8)
}
