#include "puf_mask.c"
#include "CY7C1021CV26_SRAM.h"
#include "WjCryptLib_Sha256.h"

SHA256_HASH id_digest;
SHA256_HASH pw_digest;
uint8_t final_pw_digest[16][DIGEST_SIZE] = {'\0'};
uint8_t lmd[512]={'\0'};
uint32_t address_16bit[CR_SIZE];
uint8_t id_buff[MSG_SIZE] = {0};
uint8_t pass_buff[MSG_SIZE] = {0};
uint8_t result[MSG_SIZE];
uint8_t id_size = 0;
uint8_t pass_size = 0;
uint8_t challenge[28];
char str_temp[20];

void make_xor(void);
void sha2_hash(void);
void sha2_shift(void);
void sha2_make_address(void);
void sha2_restart(void);
void hex_to_binary(uint16_t hex_data, char *buff);

void setup() {
  sramInit();

  Serial.begin(115200);
}

void loop(){
  uint16_t i_counter = 0;
  char recv_char = 0;
  
  Serial.print("\n\r\n\rEnter your ID\n\r");
  recv_char = 0;
  i_counter = 0;
  while ((recv_char != '\n') && (recv_char != '\r') && (i_counter < MSG_SIZE))
  {
    if(Serial.available())
    {
      recv_char = Serial.read();
      Serial.write(recv_char);          // echo to terminal
      id_buff[i_counter++] = recv_char; // queue character into buffer
    }
  }
  id_buff[i_counter-1] = '\0';          // the last character was enter, then replace it with NULL
  id_size = i_counter-1;

  Serial.print("\n\r\n\rEnter your Password\n\r");
  recv_char = 0;
  i_counter = 0;
  while ((recv_char != '\n') && (recv_char != '\r') && (i_counter < MSG_SIZE))
  {
    if(Serial.available())
    {
      recv_char = Serial.read();
      Serial.write(recv_char);        // echo to terminal
      pass_buff[i_counter++] = recv_char;   // queue character into buffer
    }
  }
  pass_buff[i_counter-1] = '\0';          // the last character was enter, then replace it with NULL
  pass_size = i_counter-1;
    
  Serial.print("\n\r\n\rEntered ID:\n\r0X");
  for(i_counter = 0; i_counter < id_size; i_counter++)
  {
    sprintf(str_temp, "%02X ", id_buff[i_counter]);
    Serial.print(str_temp);
  }
  Serial.print("\n\rEntered Password:\n\r0X");
  for(i_counter = 0; i_counter < pass_size; i_counter++)
  {
    sprintf(str_temp, "%02X ", pass_buff[i_counter]);
    Serial.print(str_temp);
  }   

  make_xor();
  sha2_hash();
  sha2_shift();
  sha2_make_address();
  sram_addr_correction();
  sram_read_cr();
  clear_buff(pass_buff, MSG_SIZE);
  clear_buff(id_buff, MSG_SIZE);
}

//-------------------------------------------------------------------------------------------------------------//
void make_xor(void)
{
  uint16_t i_counter = 0;
    
  for(i_counter = 0; i_counter < MSG_SIZE; i_counter++)
  {
    result[i_counter] = pass_buff[i_counter] ^ id_buff[i_counter];
  }
  
  Serial.print("\n\r\n\rID XOR PW XOR INDEX:\n\r0X");
  for(i_counter = 0; i_counter < MSG_SIZE; i_counter++)
  {
    sprintf(str_temp, "%02X ", result[i_counter]);
    Serial.print(str_temp);
  } 
}

void sha2_hash(void)
{
  uint16_t    i_counter = 0;
  
  // hash XOR result    
  Sha256Calculate(result, MSG_SIZE, &id_digest);
  Serial.print("\n\r\n\rH(ID XOR PW XOR INDEX):\n\r0X");
  for(i_counter = 0; i_counter < MSG_SIZE; i_counter++)
  {
    sprintf(str_temp, "%02X ", id_digest.bytes[i_counter]);
    Serial.print(str_temp);
  }
  // hash password
  Sha256Calculate(pass_buff, MSG_SIZE, &pw_digest);
  Serial.print("\n\r\n\rH(PW XOR INDEX):\n\r0X");
  for(i_counter = 0; i_counter < MSG_SIZE; i_counter++)
  {
    sprintf(str_temp, "%02X ", pw_digest.bytes[i_counter]);
    Serial.print(str_temp);
  }
}

void sha2_shift(void)
{
  uint16_t i_counter = 0;
  uint16_t j_count  = 0;
  uint16_t local_var = 0;
  uint16_t k;
  uint8_t second_hash_buff[32];
  SHA256_HASH temp_digest;
  
  local_var = (pw_digest.bytes[0] << 8);    // the first byte locate in higher pos.
  local_var |= pw_digest.bytes[1];          // the second byte locate in lower pos.
  
  for (i_counter = 0; i_counter < MSG_SIZE; i_counter++)  // transfer the first hashed result of data into final buffer
  {
    final_pw_digest[0][i_counter] = pw_digest.bytes[i_counter];
  }
    
  for (i_counter = 2; i_counter < MSG_SIZE; i_counter++)  // transfer the fixed part of data into hash input buffer
  {
    second_hash_buff[i_counter] = pw_digest.bytes[i_counter];
  }
  
  Serial.print("\n\r\n\rShift result:\n\r");
  //hex_to_binary(local_var, str_temp);
  //Serial.print(str_temp);

  for(j_count = 0; j_count < MSG_SIZE; j_count++)
  {
    sprintf(str_temp, "%02X ", pw_digest.bytes[j_count]);
    Serial.print(str_temp);
  }
  Serial.print("\n\r");
  
  for (i_counter = 1; i_counter < DIGEST_NUM; i_counter++)
  {
    local_var = (local_var << 1) | (local_var >> 15); // circular shift local_var[0]-[15]
    second_hash_buff[0] = (local_var>>8) & 0xFF;
    second_hash_buff[1] = (local_var & 0XFF);

    Sha256Calculate(second_hash_buff, MSG_SIZE, &temp_digest);
    for(j_count = 0; j_count < MSG_SIZE; j_count++)
      final_pw_digest[i_counter][j_count] = temp_digest.bytes[j_count];
    //hex_to_binary(local_var, str_temp);
    //Serial.print(str_temp);
    sprintf(str_temp, "%02X ", second_hash_buff[0]);
    Serial.print(str_temp);
    sprintf(str_temp, "%02X ", second_hash_buff[1]);
    Serial.print(str_temp);
    for(j_count = 2; j_count < MSG_SIZE; j_count++)
    {
      sprintf(str_temp, "%02X ", pw_digest.bytes[j_count]);
      Serial.print(str_temp);
    }
    Serial.print("\n\r");
  }
  
  // print final hash results
  Serial.print("\n\r\n\r8 MD results:\n\r");
  
  for (k = 0; k < DIGEST_NUM; k++)
  {
    Serial.print("MD");
    Serial.print(k+1, DEC);
    Serial.print(": ");
    for (int l = 0; l < DIGEST_SIZE; l++)
    {
//      if(l == 16)
//        Serial.print("\n\r     ");
      sprintf(str_temp, "%02X ", final_pw_digest[k][l]);
      Serial.print(str_temp);
      lmd[((k*32)+l)] = final_pw_digest[k][l]; // generate the long massage digest
    }
    Serial.print("\n\r");
  }
  
  Serial.print("\n\r\n\rLong Massage Digest\n\r");   // it is concatenated of 8 MD results
  for(k=0; k < DIGEST_NUM * DIGEST_SIZE; k++)
  {
    if(k % 32 == 0)
        Serial.print("\n\r");
    sprintf(str_temp, "%02X ", lmd[k]);
    Serial.print(str_temp);
  }
}

void sha2_make_address(void)
{
  uint16_t k;

  for (k = 0; k < (DIGEST_NUM * DIGEST_SIZE); k+=2) // need to revise
  {
    address_16bit[k/2]  = (lmd[k+1] << 8) | lmd[k];
  }

  Serial.print("\n\r\n\rRaw addresses:\n\r");
  for (k = 0; k < CR_SIZE; k++)
  {
//    if(k % 16 == 0)
//        Serial.print("\n\r");
    sprintf(str_temp, "%04X ", address_16bit[k]);
    Serial.print(str_temp);
  }
}

void sram_addr_correction()
{
  uint8_t i_counter = 0;
  bool read_bit = 1;
  uint8_t bits_array[CR_SIZE] = {'\0'};
  bool bit_read_flag = 1;
  
  Serial.print("\n\r\n\rRefined addresses:\n\r");
  
  for(i_counter = 0 ; i_counter < CR_SIZE; i_counter++)
  {
    bit_read_flag = 1;
    while (1)         // if reads fuzzy bit
    {
      // puf_mask[address_18bit[i_counter] >> 3] reads the whole byte at that addr
      read_bit = (puf_mask[address_16bit[i_counter] >> 3] & (1 << (address_16bit[i_counter] & 0x07)));
      if(bit_read_flag)
        bits_array[i_counter] = read_bit;
      bit_read_flag = 0;        // indicates that bit mask at the raw address is read
      if(!read_bit)
      {
//         if(i_counter % 16 == 0)
//          Serial.print("\n\r");
        sprintf(str_temp, "%04X ", address_16bit[i_counter]);
        Serial.print(str_temp);
        break;
        //bits_array[bits_counter++] = (challenge[i_counter/8] >> (7 - (i_counter & 0x07) ) ) & 1;
      }
      else
      {
        address_16bit[i_counter]++;     // increment the cell address if it contains a fuzzy cell
      }
    }
  }

  Serial.print("\n\r\n\rSRAM fuzzy bits mask:\n\r");
  for(i_counter = 0; i_counter < CR_SIZE; i_counter++)
  {
    Serial.print(bits_array[i_counter], DEC);
  }
}

void hex_to_binary(uint16_t hex_data, char *buff)
{
  uint8_t i_counter;
  
  for(i_counter = 0 ; i_counter < 16; i_counter++)
  {
    *(buff++) = 0x30 + ((hex_data >> (15 - i_counter)) & 0x1); // extract the MSb (the 15th bit of hex_data)
  }
  *buff = '\0';
}
